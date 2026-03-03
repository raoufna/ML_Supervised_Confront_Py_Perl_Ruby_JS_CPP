#!/bin/bash

EXE_NAME="./main.exe" #nome file generato dal Makefile

make clean # pulisce file

tempoInizio=$(date +%s%3N) # millisecondi

# COMPILAZIONE (Make)
make

# CONTROLLO
# se make ha fallito (exit code diverso da 0)
if [ $? -ne 0 ]; then
    echo "Errore: Compilazione fallita!"
    exit 1
fi

# Controlla se il file eseguibile esiste
if [ ! -f "$EXE_NAME" ]; then
    echo "Errore: file '$EXE_NAME' non trovato!"
    exit 1
fi

# ESECUZIONE
$EXE_NAME

tempoFine=$(date +%s%3N)

# CALCOLO TOTALE
tempoTotale=$((tempoFine - tempoInizio))

echo "TEMPO TOTALE: ${tempoTotale} ms"
make clean