#START
time = Time.now

#CHECK LIBRERIE
def ensure_gem_installed(gem_name)
  begin
    require gem_name
  rescue LoadError
    puts "#{gem_name} non trovato, installazione in corso..."
    system("gem install #{gem_name}")
    Gem.clear_paths
    require gem_name
  end
end

ensure_gem_installed('csv')
ensure_gem_installed('ruby_linear_regression')

puts "All gems ready!"

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

def print_results(dataset, mcc, final_time)
  puts "Dataset: #{dataset}"
  puts "MCC: #{mcc}"
  puts "Time: #{final_time} seconds"
  puts "-" * 40
end

def fillNa_with_mean_col(x_data, y_values)
  # --- 1. Imputazione Mediana per il Target (y_values) ---
  # Estraiamo i valori non nulli e li ordiniamo
  valid_y = y_values.compact.sort
  
  if valid_y.empty?
    target_median = 0.0
  else
    mid = valid_y.size / 2
    # Se pari: media dei due centrali, se dispari: il centrale
    target_median = valid_y.size.even? ? (valid_y[mid-1] + valid_y[mid]) / 2.0 : valid_y[mid]
  end

  # Sostituiamo i nil in y_values
  cleaned_y = y_values.map { |v| v.nil? ? target_median : v }

  # --- 2. Imputazione Media per le Feature (x_data) ---
  num_columns = x_data.first.size
  cleaned_x = x_data.map(&:dup) # Creiamo una copia per non modificare l'originale

  num_columns.times do |col_idx|
    # Estraiamo i valori della colonna saltando i nil
    column_values = x_data.map { |row| row[col_idx] }.compact
    
    # Calcolo media della colonna
    mean = column_values.empty? ? 0.0 : (column_values.sum / column_values.size.to_f)

    # Applichiamo la media ai nil della colonna specifica
    cleaned_x.each { |row| row[col_idx] = mean if row[col_idx].nil? }
  end

  [cleaned_x, cleaned_y]
end

#CONFIGURAZIONE
dataset = ARGV[0] || "neuroblastoma"
dataset_path = "../../../data/Datasets/#{dataset}.csv"
thresold = 0.5
last = -1 #Indice dell'ultimo campo
x_data = [] #Array di array
y_values = []


#LETTURA DEL DATASET
CSV.foreach(dataset_path, headers: true) do |row|
  # Features: gestiamo i nil per le colonne centrali
  raw_features = row.fields[0...-1].map { |v| v.nil? || v.strip.empty? ? nil : v.to_f }
  
  # Target: gestiamo il nil per l'ultima colonna
  last_val = row.fields.last
  raw_target = (last_val.nil? || last_val.strip.empty?) ? nil : last_val.to_f
  
  x_data << raw_features
  y_values << raw_target
end

#GESTIONE DEI NIL
x_data, y_values = fillNa_with_mean_col(x_data, y_values)

y_pred = Array.new(y_values.length) #Array delle predizioni

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
  prediction = prediction > thresold ? 1 : 0 #Applica soglia
  y_pred[i] = prediction # Aggiorna il valore reale con la classificazione binaria
end

#CALCOLO MCC
mcc = mccEvaluator(y_values, y_pred)

#RISULTATI
end_time = Time.now
final_time = end_time - time
print_results(dataset, mcc, final_time)
#FINE PROGRAMMA
