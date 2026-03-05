import os

def elimina_file_bak():
    # Ottiene la directory corrente
    cartella_partenza = os.getcwd()
    contatore = 0

    print(f"Scansione in corso nella cartella: {cartella_partenza}\n")

    # os.walk attraversa l'albero delle directory
    for root, dirs, files in os.walk(cartella_partenza):
        for file in files:
            # Controlla se il file finisce con l'estensione .bak
            if file.lower().endswith('.bak'):
                percorso_completo = os.path.join(root, file)
                try:
                    os.remove(percorso_completo)
                    print(f"Eliminato: {percorso_completo}")
                    contatore += 1
                except Exception as e:
                    print(f"Errore durante l'eliminazione di {percorso_completo}: {e}")

    print(f"\n--- Operazione completata ---")
    print(f"Totale file eliminati: {contatore}")

if __name__ == "__main__":
    elimina_file_bak()