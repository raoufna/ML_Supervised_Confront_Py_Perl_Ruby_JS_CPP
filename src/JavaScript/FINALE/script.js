//START
const startTime = performance.now(); // Inizio timer

//CHECK E INSTALL REQUIRED LIBRARIES
print_lines(40, "-");
console.log("Checking required libraries...\n");

// List of libraries to check/install
libraries = ['csv-parser', 'ml-regression-multivariate-linear'];

const { execSync } = require('child_process');

libraries.forEach(lib => {
  if (!isPackageInstalled(lib)) {
    console.log(`${lib} not found. Installing...`);
    installPackage(lib);
  } else {
    console.log(`${lib} is already installed.`);
  }
});

console.log("All required libraries are available.\n");
console.log("Starting the program...\n");

//PROGRAM STARTS HERE
const fs = require('fs'); // Libreria nativa
const csv = require('csv-parser');
const MultivariateLinearRegression = require('ml-regression-multivariate-linear');
const { argv } = require('process');
dataset_name = 'neuroblastoma'; // Default

// CONFIGURAZIONE
if (argv.length > 2) {  dataset_name = argv[2];} //
const relative_path = '../../../data/Datasets/';
const CSV_FILE_PATH = `${relative_path}${dataset_name}.csv`;
const thresold = 0.5; // Soglia per convertire la predizione in 0 o 1
const mcc_precision = 10; // Precisione dei risultati
const time_precision = 5; // Precisione del tempo in secondi
const X = []; // Matrice delle features
const y = []; // Vettore del target

fs.createReadStream(CSV_FILE_PATH)
  .pipe(csv())
  .on('data', (row) => {
    // Salva i valori di ogni riga come numeri o null
    const values = Object.values(row).map(val => {      
      const parsed = parseFloat(val);// Restituisce NaN se val è vuoto o non è un numero
      return isNaN(parsed) ? null : parsed; 
    });
    
    const targetValue = values.pop(); // Rimuove e salva l'ultimo elemento (y)
    const features = values;          // Contiene solo le features (X)

    X.push(features); 
    y.push([targetValue]); // La libreria ml-regression vuole y come matrice colonna [[0], [1], ...]
  })
  .on('end', () => {
    // Sostituzione features(X) con la media
    const nFeatures = X[0].length;
    for (let j = 0; j < nFeatures; j++) {
      let sum = 0;
      let count = 0;
      
      // Calcolo somma e conteggio per la colonna j
      for (let i = 0; i < X.length; i++) {
        if (X[i][j] !== null) {
          sum += X[i][j];
          count++;
        }
      }
      
      const mean = count > 0 ? sum / count : 0; // Calcolo media (0 se colonna vuota)
      
      // Sostituzione dei null con la media calcolata
      for (let i = 0; i < X.length; i++) {
        if (X[i][j] === null) {
          X[i][j] = mean;
        }
      }
    }

    // Sostituzione target(Y) con la mediana
    let validY = []; //Array per i valori di y non null
    for (let i = 0; i < y.length; i++) {
      if (y[i][0] !== null) {
        validY.push(y[i][0]);
      }
    }
    
    // Calcolo della mediana
    validY.sort((a, b) => a - b);
    let median = 0;
    if (validY.length > 0) {
      const mid = Math.floor(validY.length / 2);
      median = validY.length % 2 !== 0 ? validY[mid] : (validY[mid - 1] + validY[mid]) / 2;
    }

    // Sostituzione dei null con la mediana
    for (let i = 0; i < y.length; i++) {
      if (y[i][0] === null) {
        y[i][0] = median;
      }
    }

    //LEAVE-ONE-OUT CROSS-VALIDATION (LOOCV) e CALCOLO MCC
    const MCC = LOOCV_loop(X, y);
    const endTime = performance.now();
    const final_time = (endTime - startTime)/ 1000;  // Conversione in secondi
    print_results(dataset_name, MCC, final_time) //STAMPA
    //FINE PROGRAMMA
  });

//METODI
function isPackageInstalled(lib) {
  try {
    // Controlla se il pacchetto è installato localmente
    execSync(`npm list ${lib}`, { stdio: 'ignore' });
    return true;
  } catch (err) {
    return false;
  }
}

function installPackage(lib) {
  try {
    execSync(`npm install ${lib}`, { stdio: 'inherit' }); // INSTALLA PACCHETTO, stdio: 'inherit' mostra l'output del processo in tempo reale
    console.log(`${lib} installed successfully.`);
  } catch (err) {
    console.error(`Failed to install ${lib}:`, err);
  }
}

function LOOCV_loop(X, y) {
  let pred_values = []; // Vettore delle predizioni(y)

  const nSamples = X.length;

  for (let i = 0; i < nSamples; i++) {
    const X_test = X[i];      
    const Y_test = y[i][0];

    const X_train = X.filter((_, index) => index !== i);
    const Y_train = y.filter((_, index) => index !== i);

    //ADDESTRAMENTO
    let model = new MultivariateLinearRegression(X_train, Y_train);

    //PREDIZIONE
    const predictionVector = model.predict([X_test]); 
    const predictedValue = predictionVector[0][0]; // model restituisce [[val]]

    const predictedClass = predictedValue > thresold ? 1 : 0; // soglia

    pred_values.push(predictedClass);
  }

  //RISULTATI
  const mcc = MCCEvaluator(pred_values, y.map(v => v[0])).toFixed(mcc_precision);
  return mcc
}

function MCCEvaluator(pred_values, true_values) {
  let TP = 0, TN = 0, FP = 0, FN = 0; 
  for (let i = 0; i < pred_values.length; i++) {
    if (pred_values[i] === 1 && true_values[i] === 1) TP++;
    if (pred_values[i] === 0 && true_values[i] === 0) TN++;
    if (pred_values[i] === 1 && true_values[i] === 0) FP++;
    if (pred_values[i] === 0 && true_values[i] === 1) FN++;
  } 
  const numerator = (TP * TN) - (FP * FN);
  const denominator = Math.sqrt((TP + FP) * (TP + FN) * (TN + FP) * (TN + FN));
  if (denominator === 0) return 0.0;
  return numerator / denominator;
}

function print_lines(n, elem){
  line = elem
  for (let i = 0; i < n; i++) {
    line += elem;    
  }
  console.log(line)
}

function print_results(dataset_name, mcc, time){
  console.log('Dataset:', dataset_name);
  console.log('MCC:', mcc);
  console.log('Time:', time.toFixed(time_precision), 'seconds'); // Fine timer e stampa del tempo di esecuzione
  print_lines(40,"-");
}