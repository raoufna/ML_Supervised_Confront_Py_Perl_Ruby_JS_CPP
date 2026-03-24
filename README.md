## Summary ##

This project consists of a suite of scripts created in various programming languages (Python, C++, Ruby, Perl, JavaScript) to compare their performance in the Machine Learning field.
For each dataset, the algorithms calculate: execution time (in seconds), energy consumed (in kWh), and Matthews correlation coefficient.

## Installation 
### Python
Required libraries:
* numpy
* pandas
* scikit-learn
* matplotlib

### Javascript
Required libraries:
* csv-parser
* ml-regression-multivariate-linear

### C++
Required libraries:
* mlpack
* armadillo

### Ruby
Required libraries:
* csv
* ruby_linear_regression

### Perl
Required libraries:
* Text::CSV
* Statistics::Regression

## Execution instructions ##
To run the code, enter the 'FINALE' folder for the desired language, then type in the console on Windows:

    py run_[language_name]_script.py [dataset_name]

or on Linux:

    python3 run_[language_name]_script.py [dataset_name]
    

To run the script without energy consumption calculation but only to view results regarding MCC and execution time calculated by the language, also in the console, for interpreted languages (Python, Perl, Ruby, JS), the command is:

    [interpreter] script.[ext] [dataset_name]

Where `interpreter` indicates the language interpreter, for example `py` for Python, `node` for Javascript, `perl` and `ruby` for their respective languages.
Instead `ext` indicates the file extension, which varies for each language.

For C++, on Linux the commands are:
    
    make clean
    make
    .\main.exe [dataset_name]

the first command is used to set it only for the current session.

On Windows, before that sequence type in the console:

    $env:Path = "C:\msys64\ucrt64\bin;C:\msys64\usr\bin;" + $env:Path

this is used to "inject" the MSYS2 terminal into the current Powershell terminal. 
The change applies only to the current session.

## An example ##

Here is an example of running the Perl script and its output:

    PS C:\...\src\Perl\FINALE> py run_perl_script.py
    [...]
    ----------------------------------------
    [...]
    Dataset: neuroblastoma 
    MCC: 0.474177118378956
    Time: 1.716356 seconds
    ----------------------------------------
    [...]
    ENERGY CONSUMED: 2.1812179687657857e-05 kWh