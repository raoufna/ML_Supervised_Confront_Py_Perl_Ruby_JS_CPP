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

On both operating systems, use the following command to download the libraries:

    pip install numpy pandas scikit-learn matplotlib
    
Replace pip with pip3 if you are using pip3.

### Javascript
Required libraries:
* csv-parser
* ml-regression-multivariate-linear

On both operating systems, use the following command to download the libraries:

    npm install csv-parser ml-regression-multivariate-linear

### C++
Required libraries:
* mlpack
* armadillo

On Windows, download the required libraries via the MSYS2 UCRT64 terminal by typing:

    pacman -S mingw-w64-ucrt-x86_64-mlpack mingw-w64-ucrt-x86_64-armadillo

On Linux:

    sudo apt install libmlpack-dev libarmadillo-dev

### Ruby
Required libraries:
* csv
* ruby_linear_regression

On both operating systems, use the following command to download the libraries:

    gem install csv ruby_linear_regression

On Linux, if an error occurs, add [sudo] before the command.

### Perl
Required libraries:
* Text::CSV
* Statistics::Regression

On both operating systems, use the following command to download the libraries:

    cpan Text::CSV Statistics::Regression

On Linux, if an error occurs, add [sudo] before the command.

## Execution instructions ##
To run the code, enter the 'FINALE' folder for the desired language, then type the following in the console on Windows:

    py run_[language_name]_script.py [dataset_name]

or on Linux:

    python3 run_[language_name]_script.py [dataset_name]
    

To run the script without energy consumption calculation and only view results regarding MCC and execution time calculated by the language, type the following command in the console for interpreted languages (Python, Perl, Ruby, JS):

    [interpreter] script.[ext] [dataset_name]

Where `interpreter` indicates the language interpreter, for example `py` for Python, `node` for Javascript, `perl` and `ruby` for their respective languages.
The `ext` indicates the file extension, which varies for each language.

For C++, on Linux the commands are:
    
    make clean
    make
    .\main.exe [dataset_name]

The first command is used to set it only for the current session.

On Windows, run the following command in the console first:

    $env:Path = "C:\msys64\ucrt64\bin;C:\msys64\usr\bin;" + $env:Path

This is used to "inject" the MSYS2 terminal into the current PowerShell terminal. 
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