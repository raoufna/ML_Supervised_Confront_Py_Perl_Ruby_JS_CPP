#include "globals.hpp"

int main() {
    std::string relative_path = "../../../data/Datasets/";
    std::string dataset_name = spain_cardiac_arrest;
    arma::mat data = LoadData(relative_path + dataset_name); //carica il dataset

    arma::rowvec Y_values = data.row(data.n_rows-1);  // salva il vettore soluzione(y)
    data.shed_row(data.n_rows-1); // rimuove l'ultima riga(y) da data
    
    arma::rowvec y_pred = LeaveOneOutCV(data, Y_values);
    double_t finalMCC = MCCEvaluator::Calculate(y_pred, Y_values);
    
    
    //SINTASSI DI STAMPA
    std::cout << std::string(40, '-') << std::endl;
    std::cout << "Dataset: " << dataset_name << std::endl;
    std::cout << "MCC: " << std::fixed << std::setprecision(mcc_precision) << finalMCC << std::endl;
    //TIME IS PRINTED OUTSIDE
    return 0;
}