#START
import time
start = time.time() # timer start 

import subprocess
import sys

#CHECK E INSTALL REQUIRED LIBRARIES
print("-" * 40 + "\n")
print("Checking required libraries...\n")

bash_command = sys.executable +" -m pip install --upgrade pip"
# Execute the bash command
print("bash_command:\n", bash_command)
result = subprocess.run(bash_command, shell=True, capture_output=True, text=True)

# List of libraries to check/install
libraries = ["numpy", "pandas", "scikit-learn"]

for lib in libraries:
    try:
        __import__(lib)
        print(f"{lib} is already installed.")
    except ImportError:
        print(f"{lib} not found. Installing...")
        subprocess.check_call([sys.executable, "-m", "pip", "install", lib])

# Print the output and errors (if any)
print("output:\t", result.stdout)
error = result.stderr
if(error):
    print("errors:\t", error)

print("All required libraries are available.\n")
print("Starting the program...\n")

#PROGRAM STARTS HERE
import pandas as pd
from sklearn.linear_model import LinearRegression
from sklearn.model_selection import LeaveOneOut
from sklearn.metrics import matthews_corrcoef


#METODI
def leave_one_out(dataset):
    last_col = dataset.columns[len(dataset.columns)-1] # prendo il nome dell'ultima colonna del csv
    X = dataset.drop(last_col, axis=1).values
    y = dataset[last_col].values

    threshold = 0.5 # soglia per classificare in 0 o 1

    loo = LeaveOneOut()
    prediction_values = [] # lista per i valori predizione
    real_values = [] # lista per i valori reali

    for train_index, test_index in loo.split(X):

        X_train, X_test = X[train_index], X[test_index]
        y_train, y_test = y[train_index], y[test_index]
        
        model = LinearRegression()
        model.fit(X_train, y_train)

        y_pred = model.predict(X_test)
        y_pred = (y_pred > threshold).astype(int) # assegna il risultato a 0 o 1 in base alla soglia

        prediction_values.append(y_pred[0])  
        real_values.append(y_test[0])
    
    mcc = matthews_corrcoef(real_values, prediction_values)

    return mcc

def fillNa_with_mean_col(dataset):
    for i in range(len(dataset)):
        for j in range(len(dataset.columns)):
            if j == len(dataset.columns)-1 and pd.isna(dataset.iloc[i, j]): # se è l'ultima colonna (colonna target) e il valore è NaN
                dataset.iloc[i, j] = dataset.iloc[:, j].median() # assegna il valore mediano della colonna target

            if pd.isna(dataset.iloc[i, j]): # se il valore è NaN
                dataset.iloc[i, j] = dataset.iloc[:, j].mean() # assegna il valore medio della colonna

def print_results(dataset, mcc, final_time):
    print(f"Dataset: {dataset}")
    print(f"MCC: {mcc}")
    print(f"Time: {final_time} seconds\n")
    print("-" * 40 + "\n")

if __name__ == "__main__":
    
    #CONFIGURAZIONE
    dataset_name = sys.argv[1] if len(sys.argv) > 1 else "neuroblastoma"
    dataset_path = f"../../../data/Datasets/{dataset_name}.csv"
    mcc_precision = 10 # numero di cifre decimali per il MCC
    time_precision = 5  # numero di cifre decimali per il tempo di esecuzione

    #LETTURA DEL DATASET
    data = pd.read_csv(dataset_path)
    fillNa_with_mean_col(data) # per sistemare valori NaN con la media della colonna
    
    #LEAVE-ONE-OUT CROSS-VALIDATION (LOOCV) e CALCOLO MCC
    mcc = round(leave_one_out(data), mcc_precision) # calcola il MCC e arrotonda a mcc_precision cifre decimali

    #RISULTATI    
    end = time.time()
    final_time = round(end - start, time_precision) # calcola il tempo finale e arrotonda a time_precision cifre decimali
    
    print_results(dataset_name, mcc, final_time)
#FINE PROGRAMMA



