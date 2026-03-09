import os
import shutil

def delete_files_ext():
    # Ottiene la directory corrente
    cartella_partenza = os.getcwd()
    contatore = 0

    print(f"Scansione in corso nella cartella: {cartella_partenza}\n")

    # os.walk attraversa l'albero delle directory
    for root, dirs, files in os.walk(cartella_partenza+"/src"):
        for file in files:
            # Controlla se il file finisce con l'estensione .bak
            if file.lower().endswith('.bak') or file.lower().endswith('.csv') or file.lower().endswith('.o') or file.lower().endswith('.exe') or file.lower().endswith('.json'):
                percorso_completo = os.path.join(root, file)
                try:
                    os.remove(percorso_completo)
                    print(f"Eliminato: {percorso_completo}")
                    contatore += 1
                except Exception as e:
                    print(f"Errore durante l'eliminazione di {percorso_completo}: {e}")

    print(f"\n--- Operazione completata ---")
    print(f"Totale file eliminati: {contatore}")

def delete_node_modules():
        cartella_partenza = os.getcwd()
        contatore = 0
        percorso_js = os.path.join(cartella_partenza, "src/Javascript")

        print(f"Scansione in corso nella cartella: {percorso_js}\n")

        for root, dirs, files in os.walk(percorso_js):
            if "node_modules" in dirs:
                percorso_node_modules = os.path.join(root, "node_modules")
                try:
                    shutil.rmtree(percorso_node_modules)
                    print(f"Eliminata cartella: {percorso_node_modules}")
                    contatore += 1
                except Exception as e:
                    print(f"Errore durante l'eliminazione di {percorso_node_modules}: {e}")
                dirs.remove("node_modules")

        print(f"\n--- Operazione completata ---")
        print(f"Totale cartelle node_modules eliminate: {contatore}")

if __name__ == "__main__":
    delete_files_ext()
    delete_node_modules()