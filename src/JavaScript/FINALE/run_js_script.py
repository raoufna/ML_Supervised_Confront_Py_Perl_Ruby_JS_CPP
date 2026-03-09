import subprocess
import sys

#CHECK E INSTALL CODECARBON
print("Checking required libraries for CodeCarbon...")

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

tracker = EmissionsTracker()
tracker.start()

try:
    dataset_name = sys.argv[1] if len(sys.argv) > 1 else "neuroblastoma" # CHANGE DATASET HERE
    argomenti = ["node", "script.js", dataset_name]
    
    subprocess.run(argomenti, check=True)
finally:
    tracker.stop()

    df = pd.read_csv("emissions.csv") # READ FILE
    ultimo_kwh = df["energy_consumed"].iloc[-1] # GET the last energy_consumed value

    print(f"ENERGY CONSUMED: {ultimo_kwh} kWh")
