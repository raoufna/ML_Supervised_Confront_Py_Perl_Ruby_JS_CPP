#include "globals.hpp"

/** 
    GLOBAL VARIABLES
    relative path to the folder containing the datasets
    and dataset names used WITHOUT ".csv".
*/
extern const std::string relative_path = "../../../data/Datasets/"; // If directory changes, edit here
extern const std::string depression_heart_failure = "depression_heart_failure";
extern const std::string diabetes_type_1 = "diabetes_type_1";
extern const std::string neuroblastoma = "neuroblastoma";
extern const std::string sepsis_SIRS = "sepsis_SIRS";
extern const std::string spain_cardiac_arrest = "spain_cardiac_arrest";

extern const int mcc_precision = 15; // Precision for printing results

/**
 * Calculates the Matthews Correlation Coefficient (MCC).
 * @param predictions Vector of predictions.
 * @param trueLabels Vector of true labels.
 * @param threshold Threshold for classifying predictions.
 * @return double Calculated MCC value.
 */
double MCCEvaluator::Calculate(const arma::rowvec& predictions, const arma::rowvec& trueLabels, double threshold) {
    long long TP = 0, TN = 0, FP = 0, FN = 0;

    for (size_t i = 0; i < predictions.n_elem; ++i) {
        
        int predictedClass = (predictions[i] > threshold) ? 1 : 0; // Threshold
        int trueClass = (int)trueLabels[i];

        // Confusion matrix
        if (trueClass == 1 && predictedClass == 1) TP++;
        else if (trueClass == 0 && predictedClass == 0) TN++;
        else if (trueClass == 0 && predictedClass == 1) FP++;
        else if (trueClass == 1 && predictedClass == 0) FN++;
    }

    // Calculate MCC formula
    double numerator = ((double)TP * TN) - ((double)FP * FN);
    double denominator = std::sqrt(((double)TP + FP) * ((double)TP + FN) * ((double)TN + FP) * ((double)TN + FN));

    if (denominator == 0) return 0.0;
    return numerator / denominator;
}

/**
 * Loads a CSV into a matrix starting from the second row.
 * Avoids crashes due to special characters in the header.
 * @param filename Path of the .csv file
 * @return arma::mat The transposed matrix.
 */
arma::mat LoadData(const std::string& filename) {
    std::ifstream file(filename);
    if (!file.is_open()) {
        throw std::runtime_error("[LoadData] Unable to open file: " + filename);
    }

    std::string line, cell, header;
    std::vector<std::vector<double>> temp_data;
    size_t max_cols = 0;

    // Skips the header
    std::getline(file, header);

    // Parsing line by line
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
        // If the line ends with a comma, add NaN for missing target
        if (!line.empty() && line.back() == ',') {
            row.push_back(std::numeric_limits<double>::quiet_NaN());
        }

        max_cols = std::max(max_cols, row.size());
        temp_data.push_back(row);
    }

    // Manual initialization during copying
    arma::uword n_rows = temp_data.size();
    arma::uword n_cols = (arma::uword)max_cols;
    arma::mat matrix(n_rows, n_cols);

    for (arma::uword i = 0; i < n_rows; ++i) {
        for (arma::uword j = 0; j < n_cols; ++j) {
            // If the cell exists in the vector, copy it
            if (j < temp_data[i].size()) {
                matrix(i, j) = temp_data[i][j];
            } else {
                // If the cell does NOT exist (short row), set EXPLICIT NaN
                // This definitively removes "incomprehensible" numbers
                matrix(i, j) = std::numeric_limits<double>::quiet_NaN();
            }
        }
    }

    // Handling NaN
    for (arma::uword j = 0; j < n_cols; ++j) {
        // Extract the column in a arma::vec to avoid compilation errors on subview
        arma::vec col_ptr = matrix.col(j); 
        arma::uvec finite_idx = arma::find_finite(col_ptr);
        arma::uvec nan_idx = arma::find_nonfinite(col_ptr);

        if (!nan_idx.is_empty()) {
            if (!finite_idx.is_empty()) {
                double replacement_val;
                arma::vec valid_values = col_ptr.elem(finite_idx);

                if (j == n_cols - 1) { // Target column
                    replacement_val = arma::as_scalar(arma::median(valid_values));
                } else { // Feature
                    replacement_val = arma::as_scalar(arma::mean(valid_values));
                }

                // Replace NaN values in the original matrix
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
 * Performs Leave-One-Out Cross-Validation.
 * @param data Feature matrix.
 * @param Y_values Label vector. 
 * @return arma::rowvec Vector of predictions.
 */
arma::rowvec LeaveOneOutCV(const arma::mat& data, const arma::rowvec& Y_values) {
    size_t n_test = data.n_cols; // Number of samples
    arma::rowvec s_pred;
    arma::rowvec y_pred(n_test); // Predictions vector

    //LOOCV LOOP
    for (size_t i = 0; i < n_test; i++)
    {
        arma::mat X_test = data.col(i); // Test sample

        arma::mat X_train = data;
        X_train.shed_col(i);   // Training vector

        arma::rowvec Y_train = Y_values;
        Y_train.shed_col(i);
        mlpack::LinearRegression model(X_train, Y_train, 0.01);
        model.Predict(X_test,s_pred);

        y_pred(i) = s_pred(0);
    }

    return y_pred;
}

/**
 * Console output of results.
 * @param dataset_name the name of the dataset.
 * @param MCC the value of Matthews Correlation Coefficient.
 * 
 * Together with the py script, which calculates the time, it will print to console:
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