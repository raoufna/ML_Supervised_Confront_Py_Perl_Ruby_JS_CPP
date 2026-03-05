#START
my $time = time;

use strict;
use warnings;
use List::Util qw(sum);

#CHECK AND INSTALL REQUIRED LIBRARIES
print "-" x 40 . "\n";
print "Checking required libraries...\n";

my @libraries = ('Text::CSV','Statistics::Regression');
foreach my $lib (@libraries) {
    eval "use $lib";
    if ($@) {
        print "$lib not found. Installing...\n";
        system("cpan -i $lib") == 0
            or die "Error while installing $lib: $!";
    } else {
        print "$lib is already installed.\n";
    }
}

print "All required libraries are available.\n";
print "Starting the program...\n";
#PROGRAM STARTS HERE

#CONFIGURAZIONE
my $dataset = $ARGV[0] || 'neuroblastoma'; #Dataset input, default 'neuroblastoma'
my $dataset_path = '../../../data/Datasets/' . $dataset . '.csv'; #Path del dataset
my $thresold = 0.5; #Soglia
my $predictions = []; #Array delle predizioni
my $real_values = []; #Array dei valori reali

#LETTURA DEL DATASET
my $csv = Text::CSV->new({ binary => 1, auto_diag => 1 });
open my $fh, "<", $dataset_path or die "Errore: $!"; #Apre il file in lettura o lancia un errore

my $header = $csv->getline($fh); #colonna target
my @data; 
while (my $row = $csv->getline($fh)) {
    push @data, $row if scalar(@$row) > 1;
}
close $fh;

#RIEMPIMENTO DEI VALORI NaN
fillNa_with_mean_col(\@data);
#LEAVE-ONE-OUT CROSS-VALIDATION (LOOCV)

my $num_features = scalar(@{$data[0]}) - 1; # Tutte le colonne tranne l'ultima (target)

for my $i (0 .. $#data) {
    my $model = Statistics::Regression->new("Modello_$i", ["const", map { "X$_" } (1..$num_features)]); # crea un nuovo modello di regressione per ogni iterazione, con una costante e i nomi delle feature
    
    for my $j (0 .. $#data) {
        next if $i == $j; # Salta la riga che useremo per il test
        
        my @train_row = @{$data[$j]}; # Copia la riga j-esima
        my $y_train = pop @train_row;       # Estrae e rimuove l'ultimo valore (target)
        my @x_train = (1, @train_row);      # Prepara le X aggiungendo '1' per la costante
        #@x_train è un array che contiene i valori delle feature per la riga j, con '1' come primo elemento per rappresentare la costante (intercetta) del modello di regressione. Questo è necessario perché il modello di regressione include un termine costante che non dipende da nessuna feature specifica.    

        $model->include($y_train, \@x_train); # "Insegna" il punto al modello, \@x_train è un riferimento all'array @x_train
    }
    #test_row estrae l'array della riga di test contenuta nel reference $data[$i]
    my @test_row = @{$data[$i]};
    my $y_value = pop @test_row; # Il valore reale che dovremmo ottenere
    
    #CALCOLO PREDIZIONE
    #ATTENZIONE i coefficienti possono essere in una matrice o in una lista semplice a seconda della versione della libreria, assicurati di estrarli correttamente
    my @coeffs_list = $model->theta; # Estrae i coefficienti calcolati dal training
    my $y_pred = shift @coeffs_list; # Inizializza la predizione con il termine costante (intercetta)

    for my $k (0 .. $#test_row) {
        $y_pred += $coeffs_list[$k] * $test_row[$k]; # Calcola la predizione usando i coefficienti e le feature del test
    }
    #SALVA PREDIZIONE E VALORE REALE
    $y_pred = $y_pred > $thresold ? 1 : 0; # Applica la soglia 

    push @$predictions, $y_pred;
    push @$real_values, $y_value;
}

#CALCOLO MCC
my $mcc = mccEvaluator($predictions, $real_values); # Calcola il MCC usando le previsioni e i valori reali
my $finalTime = (time+0.0) - $time; #fine tempo

#RISULTATI
FINAL_print($dataset, $mcc, $finalTime); #Stampa finale

#FINE PROGRAMMA

#METODI
sub FINAL_print{
    print "DATASET: $_[0] \n";
    print "MCC: $_[1]\n";
    print "TIME: $_[2] seconds\n";
    printf "%.5f\n", $_[2];
    print "-" x 40 . "\n";
}

sub fillNa_with_mean_col{
    my ($riferimento_matrice) = @_;
    my @matrice = @$riferimento_matrice;
    
    return unless @matrice; # Esce se la matrice è vuota

    my $num_righe   = scalar @matrice;
    my $num_colonne = scalar @{$matrice[0]};
    my $indice_target = $num_colonne - 1;

    # --- 1. Calcolo Statistiche per ogni colonna ---
    my @valori_sostitutivi;

    for my $col (0 .. $indice_target) {
        my @valori_validi;
        
        # Estraiamo solo i valori numerici validi ignorando "nil" o celle vuote
        for my $riga (0 .. $num_righe - 1) {
            my $val = $matrice[$riga][$col];
            if (defined $val && $val ne "nil" && $val ne "") {
                push @valori_validi, $val;
            }
        }

        if (@valori_validi) {
            if ($col == $indice_target) {
                # Calcolo MEDIANA per il Target
                my @ordinati = sort { $a <=> $b } @valori_validi;
                my $mid = int(scalar(@ordinati) / 2);
                $valori_sostitutivi[$col] = (scalar(@ordinati) % 2) 
                    ? $ordinati[$mid] 
                    : ($ordinati[$mid-1] + $ordinati[$mid]) / 2;
            } else {
                # Calcolo MEDIA per le Features
                $valori_sostitutivi[$col] = sum(@valori_validi) / scalar(@valori_validi);
            }
        } else {
            $valori_sostitutivi[$col] = 0; # Fallback se la colonna è tutta nil
        }
    }

    # --- 2. Sostituzione dei valori NIL ---
    for my $r (0 .. $num_righe - 1) {
        for my $c (0 .. $num_colonne - 1) {
            my $val = $matrice[$r][$c];
            if (!defined $val || $val eq "nil" || $val eq "") {
                $matrice[$r][$c] = $valori_sostitutivi[$c];
            }
        }
    }

    return \@matrice;
}

sub mccEvaluator{
    my ($TP, $TN, $FP, $FN) = (0, 0, 0, 0); # Inizializza le variabili per il calcolo del MCC
    for my $i (0 .. $#$predictions){
        my $pred = $predictions->[$i];
        my $actual = $real_values->[$i];
        
        if ($pred == 1 && $actual == 1) {
           $TP++;
        } elsif ($pred == 0 && $actual == 0) {
            $TN++;
        } elsif ($pred == 1 && $actual == 0) {
            $FP++;
        } elsif ($pred == 0 && $actual == 1) {
            $FN++;
        }
    }
    my $numerator = ($TP * $TN) - ($FP * $FN);
    my $denominator = sqrt(($TP + $FP) * ($TP + $FN) * ($TN + $FP) * ($TN + $FN));
    my $mcc = $denominator == 0 ? 0 : $numerator / $denominator; # Calcola il MCC
    return $mcc;
}

sub stampa_matrice {
    my ($riferimento_matrice) = @_;
    
    # Verifichiamo che la matrice non sia vuota
    if (!defined $riferimento_matrice || scalar @$riferimento_matrice == 0) {
        print "La matrice è vuota.\n";
        return;
    }

    print "\n--- Visualizzazione Matrice ---\n";

    # Iteriamo su ogni riga della matrice
    for my $i (0 .. $#$riferimento_matrice) {
        my $riga = $riferimento_matrice->[$i];
        
        # Usiamo join per unire gli elementi della riga con un tabulatore (\t)
        # Questo mantiene le colonne allineate se i numeri hanno lunghezze simili
        print join("\t", @$riga) . "\n";
    }
    
    print "-------------------------------\n\n";
}