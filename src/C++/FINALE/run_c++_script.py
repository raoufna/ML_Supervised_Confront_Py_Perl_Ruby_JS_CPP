import subprocess
import sys

#CHECK E INSTALL REQUIRED LIBRARIES
print("Checking required libraries...")

bash_command = sys.executable +" -m pip install --upgrade pip"
# Execute the bash command
print("bash_command:\n", bash_command)
result = subprocess.run(bash_command, shell=True, capture_output=True, text=True)

# List of libraries to check/install
libraries = ["codecarbon", "pandas"]

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
from codecarbon import EmissionsTracker
import pandas as pd
import time
import subprocess
import os

subprocess.run(["make", "clean"],  check=True) #PULIZIA

tracker = EmissionsTracker()
tracker.start()
time_start = time.time()

try:
    dataset_name = sys.argv[1] if len(sys.argv) > 1 else "neuroblastoma" # CHANGE DATASET HERE
    subprocess.run("make", check=True) #COMPILAZIONE
    subprocess.run(["./main.exe", dataset_name], check=True) #ESECUZIONE   

finally:
    time_end = time.time()
    time_precision = 5  # Numero di cifre decimali per il tempo di esecuzione
    final_time = round(time_end - time_start, time_precision)
    print(f"Time: {final_time} seconds")
    print("-"*40)

    tracker.stop()

    df = pd.read_csv("emissions.csv")# Carica il file    
    ultimo_kwh = df["energy_consumed"].iloc[-1]# Prendi l'ultimo valore della colonna energy_consumed

    print(f"ENERGY CONSUMED: {ultimo_kwh} kWh")
    # subprocess.run("make clean", check=True) #PULIZIA FINALE