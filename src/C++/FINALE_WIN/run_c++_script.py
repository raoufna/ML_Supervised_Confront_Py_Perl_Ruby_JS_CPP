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

# Configurazione dei percorsi MSYS2
msys_paths = r"C:\msys64\ucrt64\bin;C:\msys64\usr\bin" # Percorso MSYS da aggiungere al PATH
print(f"Setting MSYS2 paths: {msys_paths}")
os.environ["PATH"] = msys_paths + os.pathsep + os.environ["PATH"] # Aggiorna MSYS in cima al PATH per questa sessione

subprocess.run("make clean", check=True) # PULIZIA

tracker = EmissionsTracker()
tracker.start()
start = time.time()

try:
    subprocess.run("make", check=True) # COMPILAZIONE
    subprocess.run(["./main.exe"], check=True) # ESECUZIONE   

finally:
    end = time.time()
    print(f"TIME: {end - start} seconds")
    print("-"*40)

    tracker.stop()

    df = pd.read_csv("emissions.csv")# Carica il file    
    ultimo_kwh = df["energy_consumed"].iloc[-1]# Prendi l'ultimo valore della colonna energy_consumed

    print(f"energia consumata: {ultimo_kwh} kWh")
    # subprocess.run("make clean", check=True) # PULIZIA FINALE
