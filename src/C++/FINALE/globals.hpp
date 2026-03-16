#ifndef GLOBALS_HPP
#define GLOBALS_HPP

#include <mlpack.hpp>
#include <mlpack/methods/linear_regression.hpp>
#include <armadillo>
#include <iostream>
#include <sstream>
#include <fstream>
#include <string>
#include <cmath>
#include <vector>
#include <limits>
#include <iomanip> // Required for setprecision

extern const std::string relative_path;
extern const std::string depression_heart_failure;
extern const std::string diabetes_type_1;
extern const std::string neuroblastoma;
extern const std::string sepsis_SIRS;
extern const std::string spain_cardiac_arrest;

extern const int mcc_precision;

/** Class for calculating the Matthews Correlation Coefficient (MCC). */
class MCCEvaluator {
public:
    static double Calculate(const arma::rowvec& predictions, const arma::rowvec& trueLabels, double threshold = 0.5);
};

//METHODS
arma::mat LoadData(const std::string& filename);
arma::rowvec LeaveOneOutCV(const arma::mat& data, const arma::rowvec& Y_values);
void print_results(std::string dataset_name, float MCC);

#endif