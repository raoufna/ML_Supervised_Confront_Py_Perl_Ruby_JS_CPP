#START
time = Time.now

#CHECK E INSTALL REQUIRED LIBRARIES
puts "-" * 40 + "\n"
puts "Checking required libraries...\n\n"

# List of libraries to check/install
libraries = ['csv', 'ruby_linear_regression']

def installPackage(lib)
  begin
    require lib
    puts "#{lib} is already installed."
  rescue LoadError
    puts "#{lib} not found. Installing..."
    system("gem install #{lib}")
    Gem.clear_paths
    require lib
  end
end

libraries.each { |lib| installPackage(lib) }

puts "All required libraries are available.\n\n"
puts "Starting the program...\n\n"

#PROGRAM STARTS HERE

#METODI
def mccEvaluator(real_values, predictions)
  tp = 0.0; tn = 0.0; fp = 0.0; fn = 0.0
  
  real_values.each_with_index do |val, i|
    pred = predictions[i]
    if val == 1 && pred == 1 then tp += 1
    elsif val == 0 && pred == 0 then tn += 1
    elsif val == 0 && pred == 1 then fp += 1
    elsif val == 1 && pred == 0 then fn += 1
    end
  end
  
  numerator = (tp * tn) - (fp * fn)
  denominator = Math.sqrt((tp + fp) * (tp + fn) * (tn + fp) * (tn + fn))
  
  return 0.0 if denominator == 0
  numerator / denominator
end

def print_results(datase_name, mcc, final_time)
  puts "Dataset: #{datase_name}"
  puts "MCC: #{mcc}"
  puts "Time: #{final_time} seconds"
  puts "-" * 40
end

def fillNa_with_mean_col(x_data, y_values)
  # Estraiamo i valori non nulli e li ordiniamo
  valid_y = y_values.compact.sort
  
  if valid_y.empty?
    target_median = 0.0
  else
    mid = valid_y.size / 2
    # Calcolo MEDIANA per il Target
    target_median = valid_y.size.even? ? (valid_y[mid-1] + valid_y[mid]) / 2.0 : valid_y[mid]
  end

  # Sostituzione dei valori nil in y_values
  cleaned_y = y_values.map { |v| v.nil? ? target_median : v }

  # Gestione features(X) nil con la media
  num_columns = x_data.first.size
  cleaned_x = x_data.map(&:dup) # Creiamo una copia per non modificare l'originale

  num_columns.times do |col_idx|
    # Estraiamo i valori della colonna saltando i nil
    column_values = x_data.map { |row| row[col_idx] }.compact
    
    # Calcolo media della colonna
    mean = column_values.empty? ? 0.0 : (column_values.sum / column_values.size.to_f)

    # Sostituzione dei valori nil con la media
    cleaned_x.each { |row| row[col_idx] = mean if row[col_idx].nil? }
  end

  [cleaned_x, cleaned_y]
end

#CONFIGURAZIONE
datase_name = ARGV[0] || "neuroblastoma"
relative_path = "../../../data/Datasets/" # se il percorso ai dataset cambia, agire qui
dataset_path = relative_path + datase_name + ".csv"
thresold = 0.5
last = -1 # Indice dell'ultimo campo
x_data = [] # Array di array
y_values = []


#LETTURA DEL DATASET
CSV.foreach(dataset_path, headers: true) do |row|
  raw_col = row.fields.map { |v| v.nil? || v.strip.empty? ? nil : v.to_f } # Assegna nil
  
  x_data << raw_col[0...-1] # Salva le features(X)
  y_values << raw_col[-1] # Salva l'ultimo valore(y)
end

# Riempimento dei valori NaN
x_data, y_values = fillNa_with_mean_col(x_data, y_values)

y_pred = Array.new(y_values.length) # Array delle predizioni

#LEAVE-ONE-OUT CROSS-VALIDATION (LOOCV)
for i in 0...x_data.length
  train_x = x_data[0...i] + x_data[(i + 1)..last] #Prende tutto tranne quello in posizione i
  train_y = y_values[0...i] + y_values[(i + 1)..last] #Prende tutti i valori tranne quello in posizione i
  test_x = x_data[i]
  test_y = y_values[i]

  # MODELLO
  linear_regression = RubyLinearRegression.new
  linear_regression.load_training_data(train_x, train_y)
  linear_regression.train_normal_equation

  # PREDIZIONE
  prediction = linear_regression.predict(test_x)

  # CLASSIFICAZIONE BINARIA
  prediction = prediction > thresold ? 1 : 0 # Applica soglia
  y_pred[i] = prediction # Aggiorna il valore reale con la classificazione binaria
end

#CALCOLO MCC
mcc = mccEvaluator(y_values, y_pred)

#RISULTATI
end_time = Time.now
final_time = end_time - time
print_results(datase_name, mcc, final_time)
#FINE PROGRAMMA