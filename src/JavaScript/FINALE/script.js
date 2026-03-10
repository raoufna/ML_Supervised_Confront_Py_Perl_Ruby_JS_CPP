//START
const time_start = performance.now(); // Start timer

//CHECK AND INSTALL REQUIRED LIBRARIES
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
const fs = require('fs'); // Native library
const csv = require('csv-parser');
const MultivariateLinearRegression = require('ml-regression-multivariate-linear');
const { argv } = require('process');
dataset_name = 'neuroblastoma'; // Default

//CONFIGURATION
if (argv.length > 2) { dataset_name = argv[2]; } // Assign input dataset, if exists
const relative_path = '../../../data/Datasets/';
const CSV_FILE_PATH = `${relative_path}${dataset_name}.csv`;
const threshold = 0.5; // Threshold to convert prediction to 0 or 1
const mcc_precision = 10; // Precision of results
const time_precision = 5; // Precision of time in seconds
const X = []; // Features matrix
const y = []; // Target vector

fs.createReadStream(CSV_FILE_PATH)
  .pipe(csv())
  .on('data', (row) => {
    // Save each row values as numbers or null
    const values = Object.values(row).map(val => {      
      const parsed = parseFloat(val);// Returns NaN if val is empty or not a number
      return isNaN(parsed) ? null : parsed; 
    });
    
    const targetValue = values.pop(); // Remove and save last element (y)
    const features = values;          // Contains only features (X)

    X.push(features); 
    y.push([targetValue]); // The ml-regression library wants y as a column matrix [[0], [1], ...]
  })
  .on('end', () => {
    // Replace features(X) with the mean
    const nFeatures = X[0].length;
    for (let j = 0; j < nFeatures; j++) {
      let sum = 0;
      let count = 0;
      
      // Calculate sum and count for column j
      for (let i = 0; i < X.length; i++) {
        if (X[i][j] !== null) {
          sum += X[i][j];
          count++;
        }
      }
      
      const mean = count > 0 ? sum / count : 0; // Calculate mean (0 if column is empty)
      
      // Replace null values with calculated mean
      for (let i = 0; i < X.length; i++) {
        if (X[i][j] === null) {
          X[i][j] = mean;
        }
      }
    }

    // Replace target(Y) with the median
    let validY = []; // Array for non-null y values
    for (let i = 0; i < y.length; i++) {
      if (y[i][0] !== null) {
        validY.push(y[i][0]);
      }
    }
    
    // Calculate median
    validY.sort((a, b) => a - b);
    let median = 0;
    if (validY.length > 0) {
      const mid = Math.floor(validY.length / 2);
      median = validY.length % 2 !== 0 ? validY[mid] : (validY[mid - 1] + validY[mid]) / 2;
    }

    // Replace null values with median
    for (let i = 0; i < y.length; i++) {
      if (y[i][0] === null) {
        y[i][0] = median;
      }
    }

    //LEAVE-ONE-OUT CROSS-VALIDATION (LOOCV) AND MCC CALCULATION
    const MCC = LOOCV_loop(X, y);
    const time_end = performance.now();
    const final_time = (time_end - time_start)/ 1000;  // Convert to seconds
    print_results(dataset_name, MCC, final_time) //PRINT
    //END PROGRAM
  });

//METHODS
function isPackageInstalled(lib) {
  try {
    // Check if package is installed locally
    execSync(`npm list ${lib}`, { stdio: 'ignore' });
    return true;
  } catch (err) {
    return false;
  }
}

function installPackage(lib) {
  try {
    execSync(`npm install ${lib}`, { stdio: 'inherit' }); //INSTALL PACKAGE, stdio: 'inherit' shows process output in real time
    console.log(`${lib} installed successfully.`);
  } catch (err) {
    console.error(`Failed to install ${lib}:`, err);
  }
}

function LOOCV_loop(X, y) {
  let pred_values = []; // Vector of predictions(y)

  const nSamples = X.length;

  for (let i = 0; i < nSamples; i++) {
    const X_test = X[i];      
    const Y_test = y[i][0];

    const X_train = X.filter((_, index) => index !== i);
    const Y_train = y.filter((_, index) => index !== i);

    //TRAINING
    let model = new MultivariateLinearRegression(X_train, Y_train);

    //PREDICTION
    const predictionVector = model.predict([X_test]); 
    const predictedValue = predictionVector[0][0]; // 'model' returns [[val]]

    const predictedClass = predictedValue > threshold ? 1 : 0; // Threshold

    pred_values.push(predictedClass);
  }

  //RESULTS
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
  console.log('Time:', time.toFixed(time_precision), 'seconds'); // End timer and print execution time
  print_lines(40,"-");
}