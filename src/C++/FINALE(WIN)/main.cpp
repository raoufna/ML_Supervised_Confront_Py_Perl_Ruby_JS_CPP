#include "globals.hpp"


int main() {
    
    arma::mat data = LoadData(spain_cardiac_arrest); //carica il dataset

    arma::rowvec Y_values = data.row(data.n_rows-1);  // salva il vettore soluzione(y)
    data.shed_row(data.n_rows-1); // rimuove l'ultima riga(y) da data
    
    arma::rowvec y_pred = LeaveOneOutCV(data, Y_values);
    double_t finalMCC = MCCEvaluator::Calculate(y_pred, Y_values);
    
    
    //SINTASSI DI STAMPA
    std::cout << "\nMCC: " << std::fixed << std::setprecision(mcc_precision) << finalMCC << std::endl;
    return 0;
}