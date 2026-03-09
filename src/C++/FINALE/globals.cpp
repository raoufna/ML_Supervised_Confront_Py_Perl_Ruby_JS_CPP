#include "globals.hpp"

/** 
    VARIABILI GLOBALI
    percorso relativo alla cartella in cui si trovano i dataset
    e nomi dei dataset utilizzati SENZA ".csv".
*/
extern const std::string relative_path = "../../../data/Datasets/"; // se cambia directory agire qui
extern const std::string depression_heart_failure = "depression_heart_failure";
extern const std::string diabetes_type_1 = "diabetes_type_1";
extern const std::string neuroblastoma = "neuroblastoma";
extern const std::string sepsis_SIRS = "sepsis_SIRS";
extern const std::string spain_cardiac_arrest = "spain_cardiac_arrest";

extern const int mcc_precision = 15; // precisione per la stampa dei risultati

/**
 * Calcola il Matthews Correlation Coefficient (MCC).
 * @param predictions Vettore delle predizioni.
 * @param trueLabels Vettore delle etichette vere.
 * @param threshold Soglia per classificare le predizioni.
 * @return double Valore MCC calcolato.
 */
double MCCEvaluator::Calculate(const arma::rowvec& predictions, const arma::rowvec& trueLabels, double threshold) {
    long long TP = 0, TN = 0, FP = 0, FN = 0;

    for (size_t i = 0; i < predictions.n_elem; ++i) {
        
        int predictedClass = (predictions[i] > threshold) ? 1 : 0; // Soglia
        int trueClass = (int)trueLabels[i];

        // Matrice di confusione
        if (trueClass == 1 && predictedClass == 1) TP++;
        else if (trueClass == 0 && predictedClass == 0) TN++;
        else if (trueClass == 0 && predictedClass == 1) FP++;
        else if (trueClass == 1 && predictedClass == 0) FN++;
    }

    // Calcolo formula MCC
    double numerator = ((double)TP * TN) - ((double)FP * FN);
    double denominator = std::sqrt(((double)TP + FP) * ((double)TP + FN) * ((double)TN + FP) * ((double)TN + FN));

    if (denominator == 0) return 0.0;
    return numerator / denominator;
}

/**
 * Carica un CSV in una matrice a partire dalla seconda riga.
 * Evita crash dovuti a caratteri speciali nell'header.
 * @param filename Percorso del file .csv
 * @return arma::mat La matrice trasposta.
 */
arma::mat LoadData(const std::string& filename) {
    std::ifstream file(filename);
    if (!file.is_open()) {
        throw std::runtime_error("[LoadData] Impossibile aprire il file: " + filename);
    }

    std::string line, cell, header;
    std::vector<std::vector<double>> temp_data;
    size_t max_cols = 0;

    // Salta l'header
    std::getline(file, header);

    // Parsing riga per riga
    while (std::getline(file, line)) {
        if (!line.empty() && line.back() == '\r') line.pop_back();
        if (line.empty()) continue;

        std::vector<double> row;
        std::stringstream lineStream(line);
        
        while (std::getline(lineStream, cell, ',')) {
            cell.erase(0, cell.find_first_not_of(" \t\n\r"));
            cell.erase(cell.find_last_not_of(" \t\n\r") + 1);

            if (cell.empty() || cell == "NA" || cell == "NaN") {
                row.push_back(std::numeric_limits<double>::quiet_NaN());
            } else {
                try {
                    row.push_back(std::stod(cell));
                } catch (...) {
                    row.push_back(std::numeric_limits<double>::quiet_NaN());
                }
            }
        }
        // Se la riga finisce con una virgola, aggiungiamo il NaN per il target mancante
        if (!line.empty() && line.back() == ',') {
            row.push_back(std::numeric_limits<double>::quiet_NaN());
        }

        max_cols = std::max(max_cols, row.size());
        temp_data.push_back(row);
    }

    // Inizializzazione manuale durante la copia
    arma::uword n_rows = temp_data.size();
    arma::uword n_cols = (arma::uword)max_cols;
    arma::mat matrix(n_rows, n_cols); // Matrice con memoria "sporca"

    for (arma::uword i = 0; i < n_rows; ++i) {
        for (arma::uword j = 0; j < n_cols; ++j) {
            // Se la cella esiste nel vector, la copiamo
            if (j < temp_data[i].size()) {
                matrix(i, j) = temp_data[i][j];
            } else {
                // Se la cella NON esiste (riga corta), mettiamo NaN ESPLICITO
                // Questo elimina definitivamente i numeri "incomprensibili"
                matrix(i, j) = std::numeric_limits<double>::quiet_NaN();
            }
        }
    }

    // Gestione dei NaN
    for (arma::uword j = 0; j < n_cols; ++j) {
        // Estraiamo la colonna in un vec per evitare errori di compilazione sulle subview
        arma::vec col_ptr = matrix.col(j); 
        arma::uvec finite_idx = arma::find_finite(col_ptr);
        arma::uvec nan_idx = arma::find_nonfinite(col_ptr);

        if (!nan_idx.is_empty()) {
            if (!finite_idx.is_empty()) {
                double replacement_val;
                arma::vec valid_values = col_ptr.elem(finite_idx);

                if (j == n_cols - 1) { // Colonna Target
                    replacement_val = arma::as_scalar(arma::median(valid_values));
                    std::cout << "mEDIANA: " << replacement_val<< std::endl;

                } else { // Feature
                    replacement_val = arma::as_scalar(arma::mean(valid_values));
                }

                // Sostituiamo i NaN nella matrice originale
                for (arma::uword r : nan_idx) {
                    matrix(r, j) = replacement_val;
                }
            } else {
                matrix.col(j).zeros();
            }
        }
    }

    return matrix.t();
}

/**
 * Esegue la Leave-One-Out Cross-Validation.
 * @param data Matrice dei dati (features).
 * @param Y_values Vettore delle etichette. 
 * @return arma::rowvec Vettore delle predizioni.
 */
arma::rowvec LeaveOneOutCV(const arma::mat& data, const arma::rowvec& Y_values) {
    size_t n_test = data.n_cols; //numero campioni
    arma::rowvec s_pred;
    arma::rowvec y_pred(n_test); //vettore predizioni

    //LOOCV LOOP
    for (size_t i = 0; i < n_test; i++)
    {
        arma::mat X_test = data.col(i); //campione del test

        arma::mat X_train = data;
        X_train.shed_col(i);   //il vettore train

        arma::rowvec Y_train = Y_values;
        Y_train.shed_col(i);
        mlpack::LinearRegression model(X_train, Y_train, 0.01);
        model.Predict(X_test,s_pred);

        y_pred(i) = s_pred(0);
    }

    return y_pred;
}

/**
 * Stampa a console dei risultati.
 * @param dataset_name il nome del dataset.
 * @param MCC il valore del coeff. di corr. di Matthews.
 * 
 * Assieme allo script py, che calcola il tempo, stamperà a console:
 * ----------------------
 * DATASET: DATASET
 * MCC: MCC
 * TIME: time(seconds)
 * ----------------------
 */
void print_results(std::string dataset_name, float MCC){
    std::cout << std::string(40, '-') << std::endl;
    std::cout << "Dataset: " << dataset_name << std::endl;
    std::cout << "MCC: " << std::fixed << std::setprecision(mcc_precision) << MCC << std::endl;
}