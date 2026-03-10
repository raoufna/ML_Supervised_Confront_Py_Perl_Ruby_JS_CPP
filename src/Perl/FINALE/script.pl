#START
use Time::HiRes qw(time);
my $time_start = time;

#CHECK AND INSTALL REQUIRED LIBRARIES
print "-" x 40 . "\n";
print "Checking required libraries...\n\n";

# List of libraries to check/install
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

print "All required libraries are available.\n\n";
print "Starting the program...\n\n";

#PROGRAM STARTS HERE
use strict;
use warnings;
use List::Util qw(sum);
use Text::CSV;
use Statistics::Regression;

#CONFIGURATION
my $dataset = $ARGV[0] || 'neuroblastoma'; # Input dataset, default 'neuroblastoma'
my $relative_path = '../../../data/Datasets/';
my $dataset_path = $relative_path . $dataset . '.csv'; # Dataset path
my $threshold = 0.5; # Threshold
my $predictions = []; # Array of predictions
my $real_values = []; # Array of real values

#DATASET READING
my $csv = Text::CSV->new({ binary => 1, auto_diag => 1 });
open my $fh, "<", $dataset_path or die "Error: $!"; # Opens file for reading or throws an error

my $header = $csv->getline($fh); # Target column
my @data; 
while (my $row = $csv->getline($fh)) {
    push @data, $row if scalar(@$row) > 1;
}
close $fh;

# Fill NaN values with column mean
fillNa_with_mean_col(\@data);

#LEAVE-ONE-OUT CROSS-VALIDATION (LOOCV)
my $num_features = scalar(@{$data[0]}) - 1; # All columns except the last (target)
for my $i (0 .. $#data) {
    my $model = Statistics::Regression->new("Model_$i", ["const", map { "X$_" } (1..$num_features)]); # Creates a new regression model for each iteration, with a constant and feature names
    
    for my $j (0 .. $#data) {
        next if $i == $j; # Skips the row we will use for test
        
        my @train_row = @{$data[$j]}; # Copy the j-th row
        my $y_train = pop @train_row;       # Extract and remove the last value (target)
        my @x_train = (1, @train_row);      # Prepare the X by adding '1' for the constant
        $model->include($y_train, \@x_train); # "Teach" the point to the model, \@x_train is a reference to @x_train array
    }
    # test_row extracts the test row array contained in the reference $data[$i]
    my @test_row = @{$data[$i]};
    my $y_value = pop @test_row; # Pop the real y value
    
    #CALCULATE PREDICTION
    #WARNING: coefficients can be in a matrix or in a simple list depending on the library version, make sure to extract them correctly
    my @coeffs_list = $model->theta; # Extract the coefficients calculated from training
    my $y_pred = shift @coeffs_list; # Initialize the prediction with the constant term (intercept)

    for my $k (0 .. $#test_row) {
        $y_pred += $coeffs_list[$k] * $test_row[$k]; # Calculate the prediction using the coefficients and test features
    }
    #SAVE PREDICTION AND REAL VALUE
    $y_pred = $y_pred > $threshold ? 1 : 0; # Apply the threshold 

    push @$predictions, $y_pred;
    push @$real_values, $y_value;
}

#CALCULATE MCC
my $mcc = mccEvaluator($predictions, $real_values);
my $final_time = time - $time_start; # End time

#RESULTS
FINAL_print($dataset, $mcc, $final_time); #PRINT

#END OF PROGRAM

#METHODS
sub FINAL_print{
    print "Dataset: $_[0] \n";
    print "MCC: $_[1]\n";
    printf "Time: %f seconds\n", $_[2]; # Time in seconds rounded
    print "-" x 40 . "\n";
}

sub fillNa_with_mean_col{
    my ($reference_matrix) = @_;
    my @matrix = @$reference_matrix;
    
    return unless @matrix; # Exit if matrix is empty

    my $num_rows   = scalar @matrix;
    my $num_cols = scalar @{$matrix[0]};
    my $target_index = $num_cols - 1;

    my @replacement_values;

    for my $col (0 .. $target_index) {
        my @valid_values;
        
        # Extract only valid numeric values ignoring "nil" or empty cells
        for my $row (0 .. $num_rows - 1) {
            my $val = $matrix[$row][$col];
            if (defined $val && $val ne "nil" && $val ne "") {
                push @valid_values, $val;
            }
        }

        if (@valid_values) {
            if ($col == $target_index) {
                # Calculate MEDIAN for the Target
                my @sorted = sort { $a <=> $b } @valid_values;
                my $mid = int(scalar(@sorted) / 2);
                $replacement_values[$col] = (scalar(@sorted) % 2) 
                    ? $sorted[$mid] 
                    : ($sorted[$mid-1] + $sorted[$mid]) / 2;
            } else {
                # Calculate MEAN for the Features
                $replacement_values[$col] = sum(@valid_values) / scalar(@valid_values);
            }
        } else {
            $replacement_values[$col] = 0; # SET 0 if the column is all nil
        }
    }

    # Replacement of NIL values
    for my $r (0 .. $num_rows - 1) {
        for my $c (0 .. $num_cols - 1) {
            my $val = $matrix[$r][$c];
            if (!defined $val || $val eq "nil" || $val eq "") {
                $matrix[$r][$c] = $replacement_values[$c];
            }
        }
    }

    return \@matrix;
}

sub mccEvaluator{
    my ($TP, $TN, $FP, $FN) = (0, 0, 0, 0); # Initialize variables for MCC calculation
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
    my $mcc = $denominator == 0 ? 0 : $numerator / $denominator;
    return $mcc;
}