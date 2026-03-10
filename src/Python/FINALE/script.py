#START
import time
time_start = time.time() # timer start 

import subprocess
import sys

#CHECK AND INSTALL REQUIRED LIBRARIES
print("-" * 40)
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


#METHODS
def leave_one_out(dataset):
    last_col = dataset.columns[len(dataset.columns)-1] # Gets the name of the last column of the csv
    X = dataset.drop(last_col, axis=1).values
    y = dataset[last_col].values

    threshold = 0.5 # Threshold for classifying as 0 or 1

    loo = LeaveOneOut()
    prediction_values = [] # List for prediction values
    real_values = [] # List for real values

    for train_index, test_index in loo.split(X):

        X_train, X_test = X[train_index], X[test_index]
        y_train, y_test = y[train_index], y[test_index]
        
        model = LinearRegression()
        model.fit(X_train, y_train)

        y_pred = model.predict(X_test)
        y_pred = (y_pred > threshold).astype(int) # Assigns the result to 0 or 1 based on the threshold

        prediction_values.append(y_pred[0])  
        real_values.append(y_test[0])
    
    mcc = matthews_corrcoef(real_values, prediction_values)

    return mcc

def fillNa_with_mean_col(dataset):
    for i in range(len(dataset)):
        for j in range(len(dataset.columns)):
            if j == len(dataset.columns)-1 and pd.isna(dataset.iloc[i, j]): # If it's the last column (target column) and the value is NaN
                dataset.iloc[i, j] = dataset.iloc[:, j].median() # Assigns the median value of the target column

            if pd.isna(dataset.iloc[i, j]): # If the value is NaN
                dataset.iloc[i, j] = dataset.iloc[:, j].mean() # Assigns the mean value of the column

def print_results(dataset, mcc, final_time):
    print(f"Dataset: {dataset}")
    print(f"MCC: {mcc}")
    print(f"Time: {final_time} seconds")
    print("-" * 40)

if __name__ == "__main__":
    
    #CONFIGURATION
    relative_path = "../../../data/Datasets/" # If the path to datasets changes, edit here
    dataset_name = sys.argv[1] if len(sys.argv) > 1 else "neuroblastoma" # Gets the dataset name from console
    dataset_path = relative_path + dataset_name + ".csv"
    mcc_precision = 10 # Number of decimal places for MCC
    time_precision = 5  # Number of decimal places for execution time

    #DATASET READING
    data = pd.read_csv(dataset_path)
    fillNa_with_mean_col(data) # To fix NaN values with the column mean
    
    #LEAVE-ONE-OUT CROSS-VALIDATION (LOOCV) AND MCC CALCULATION
    mcc = round(leave_one_out(data), mcc_precision) # Calculates the MCC and rounds to mcc_precision decimal places

    #RESULTS   
    time_end = time.time() # timer end
    final_time = round(time_end - time_start, time_precision) # Calculates the final time and rounds to time_precision decimal places
    
    print_results(dataset_name, mcc, final_time) #PRINT
#END PROGRAM