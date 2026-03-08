#ifndef GLOBALS_HPP
#define GLOBALS_HPP

#include <mlpack.hpp>
#include <mlpack/methods/linear_regression.hpp>
#include <armadillo>
#include <iostream>
#include <cmath>
#include <fstream>
#include <iomanip> // Necessario per setprecision
#include <string>
#include <sstream>
#include <vector>
#include <limits>


/** Classe per il calcolo del Matthews Correlation Coefficient (MCC). */
class MCCEvaluator {
public:
    static double Calculate(const arma::rowvec& predictions, const arma::rowvec& trueLabels, double threshold = 0.5);
};

arma::mat LoadData(const std::string& filename);
arma::rowvec LeaveOneOutCV(const arma::mat& data, const arma::rowvec& Y_values);

extern const std::string relative_path;
extern const std::string depression_heart_failure;
extern const std::string diabetes_type_1;
extern const std::string neuroblastoma;
extern const std::string sepsis_SIRS;
extern const std::string spain_cardiac_arrest;

extern const int mcc_precision;

#endif