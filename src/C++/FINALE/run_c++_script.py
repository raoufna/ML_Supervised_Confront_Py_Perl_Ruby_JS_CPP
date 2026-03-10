import subprocess
import sys

#CHECK AND INSTALL REQUIRED LIBRARIES
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

# Configuration of MSYS2 paths
msys_paths = r"C:\msys64\ucrt64\bin;C:\msys64\usr\bin" # MSYS path to add to PATH
print(f"Setting MSYS2 paths: {msys_paths}")
os.environ["PATH"] = msys_paths + os.pathsep + os.environ["PATH"] # Updates MSYS at the top of PATH for this session

subprocess.run("make clean", check=True) #CLEANING

tracker = EmissionsTracker()
tracker.start()
time_start = time.time()

try:
    dataset_name = sys.argv[1] if len(sys.argv) > 1 else "neuroblastoma" # CHANGE DATASET HERE
    subprocess.run("make", check=True) #COMPILATION
    subprocess.run(["./main.exe", dataset_name], check=True) #EXECUTION   

finally:
    time_end = time.time()
    time_precision = 5  # Number of decimal digits for execution time
    final_time = round(time_end - time_start, time_precision)
    print(f"Time: {final_time} seconds")
    print("-"*40)

    tracker.stop()

    df = pd.read_csv("emissions.csv") # Load the file    
    ultimo_kwh = df["energy_consumed"].iloc[-1] # Get the last value from energy_consumed column

    print(f"ENERGY CONSUMED: {ultimo_kwh} kWh")
    # subprocess.run("make clean", check=True) #FINAL CLEANING