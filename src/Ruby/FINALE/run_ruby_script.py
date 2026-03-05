from codecarbon import EmissionsTracker
import subprocess
import pandas as pd
import sys

tracker = EmissionsTracker()
tracker.start()

try:
    argomenti = ["ruby", "script.rb", "spain_cardiac_arrest"]
    
    subprocess.run(argomenti, check=True)
finally:
    tracker.stop()
    # Carica il file
    df = pd.read_csv("emissions.csv")

    # Prendi l'ultimo valore della colonna energy_consumed
    ultimo_kwh = df["energy_consumed"].iloc[-1]

    print(f"energia consumata: {ultimo_kwh} kWh")
