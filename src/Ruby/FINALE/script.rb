#START
time_start = Time.now

#CHECK AND INSTALL REQUIRED LIBRARIES
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

#METHODS
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
  # Extract non-null values and sort them
  valid_y = y_values.compact.sort
  
  if valid_y.empty?
    target_median = 0.0
  else
    mid = valid_y.size / 2
    # Calculate MEDIAN for the Target
    target_median = valid_y.size.even? ? (valid_y[mid-1] + valid_y[mid]) / 2.0 : valid_y[mid]
  end

  # Replace nil values in y_values
  cleaned_y = y_values.map { |v| v.nil? ? target_median : v }

  # Handle features (X) nil with the mean
  num_columns = x_data.first.size
  cleaned_x = x_data.map(&:dup) # Create a copy to not modify the original

  num_columns.times do |col_idx|
    # Extract column values skipping nils
    column_values = x_data.map { |row| row[col_idx] }.compact
    
    # Calculate column mean
    mean = column_values.empty? ? 0.0 : (column_values.sum / column_values.size.to_f)

    # Replace nil values with the mean
    cleaned_x.each { |row| row[col_idx] = mean if row[col_idx].nil? }
  end

  [cleaned_x, cleaned_y]
end

#CONFIGURATION
datase_name = ARGV[0] || "neuroblastoma"
relative_path = "../../../data/Datasets/" # If the path to datasets changes, edit here
dataset_path = relative_path + datase_name + ".csv"
threshold = 0.5
last = -1 # Index of the last field
x_data = []
y_values = []


#DATASET READING
CSV.foreach(dataset_path, headers: true) do |row|
  raw_col = row.fields.map { |v| v.nil? || v.strip.empty? ? nil : v.to_f } # Assign nil
  
  x_data << raw_col[0...-1] # Save the features (X)
  y_values << raw_col[-1] # Save the last value (y)
end

# Fill NaN values
x_data, y_values = fillNa_with_mean_col(x_data, y_values)

y_pred = Array.new(y_values.length) # Array of predictions

#LEAVE-ONE-OUT CROSS-VALIDATION (LOOCV)
for i in 0...x_data.length
  train_x = x_data[0...i] + x_data[(i + 1)..last] # Take all except the one at position i
  train_y = y_values[0...i] + y_values[(i + 1)..last] # Take all values except the one at position i
  test_x = x_data[i]
  test_y = y_values[i]

  #MODEL
  linear_regression = RubyLinearRegression.new
  linear_regression.load_training_data(train_x, train_y, false)
  linear_regression.train_normal_equation

  #PREDICTION
  prediction = linear_regression.predict(test_x)

  # BINARY CLASSIFICATION
  prediction = prediction > threshold ? 1 : 0 # Apply threshold
  y_pred[i] = prediction # Update the real value with binary classification
end

#CALCULATE MCC
mcc = mccEvaluator(y_values, y_pred)

#RESULTS
time_end = Time.now
final_time = time_end - time_start
print_results(datase_name, mcc, final_time)
#END PROGRAM