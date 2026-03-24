## Summary ##

Questo progetto consiste in una suite di script realizzati in diversi linguaggi di programmazione (Python, C++, Ruby, Perl, JavaScript) per confrontare le loro prestazioni nell'ambito del Machine Learning.
Per ogni dataset gli algoritmi calcolano: tempo di esecuzione(in secondi), energia consumata(in kWh) e il coefficiente di correlazione di Matthwes.

## Installation 
### Python
librerie necessarie:
* numpy
* pandas
* scikit-learn
* matplotlib

### Javascript
librerie necessarie:
* csv-parser
* ml-regression-multivariate-linear

### C++
librerie necessarie:
* mlpack
* armadillo

### Ruby
librerie necessarie:
* csv
* ruby_linear_regression

### Perl
librerie necessarie:
* Text::CSV
* Statistics::Regression

## Execution instructions ##
Per avviare il codice, entrare nella cartella 'FINALE' relativa al linguaggio desiderato, dopodiché a console scrivere, su windows:

    py run_[nome_linguaggio]_script.py [nome_dataset]

oppure in linux:

    python3 run_[nome_linguaggio]_script.py [nome_dataset]
    

Per avviare lo script senza il calcolo dell'energia conusmata ma solamente per vedere risultati riguardanti MCC e tempo di esecuzione calcolato dal linguaggio, sempre a console, per i linguaggi interpretati (Python, Perl, Ruby, JS), il comando è:

    [interprete] script.[ext] [nome_dataset]

Dove `interprete` indica l'interprete del linguaggio, ad es. `py` per Python, `node` per Javascript, `perl` e `ruby` per i rispettvi.
Invece `ext` indica l'estensione del file, che cambia in ogni linguaggio.

Per quanto riguarda C++, su linux i comandi sono:
    
    make clean
    make
    .\main.exe [nome_dataset]

il primo comando serve per impostare solamente per la sessione corrente

mentre su windows, prima di quella sequenza scrivere a console:

    $env:Path = "C:\msys64\ucrt64\bin;C:\msys64\usr\bin;" + $env:Path

questo serve per "iniettare" il terminale MSYS2 nel terminale Powershell corrente. 
La modifica vale solo per la sessione corrente.
## An example ##

Ecco un esempio del lancio dello script Perl e del relativo output:

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