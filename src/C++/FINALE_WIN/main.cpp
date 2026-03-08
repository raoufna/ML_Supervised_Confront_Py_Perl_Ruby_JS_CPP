#include "globals.hpp"

int main() {
    std::string relative_path = "../../../data/Datasets/";
    std::string dataset_name = spain_cardiac_arrest;
    arma::mat data = LoadData(relative_path + dataset_name + ".csv"); //carica il dataset nella matrice data

    arma::rowvec Y_values = data.row(data.n_rows-1);  // salva il vettore soluzione(y)
    data.shed_row(data.n_rows-1); // rimuove l'ultima riga(y) da data
    
    arma::rowvec y_pred = LeaveOneOutCV(data, Y_values);
    double_t finalMCC = MCCEvaluator::Calculate(y_pred, Y_values);
    
    
    //STAMPA I RISULTATI
    print_results(dataset_name, finalMCC);
    //TIME IS PRINTED OUTSIDE
    return 0;
}