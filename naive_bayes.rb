class NaiveBayes
  def initialize()
    @training_data = Utils::parse_csv
    @test_data = Hash.new([])
    @test_data_array = [] # a more convenient way to iterate through the data
    @total_items = 0
    @class_count = Hash.new(0)
    report()
  end

  # classify and report on accuracy of classification
  # using 10-fold stratified cross-validation
  def report()
    fold_accuracies = Array.new(10) { Hash.new([0,0]) }

    fold_accuracies.each_with_index do |fold_accuracy, i|
      # move current fold out of training data and into test data
      @test_data[i] = @training_data.delete(i)

      # flatten out folds into one large array, for convenience
      @training_data.each do |fold,rows|
        rows.each do |row|
          @test_data_array << row
        end
      end
      @class_count = @training_data.inject(Hash.new(0)) { |h,v| h[v.last] += 1; h }
      @total_items = @training_data.size

      # classify each row in the fold
      @test_data[i].each do |row|
        predicted = classify(row)
        actual = row.last

        # count the number of correct classifications for each class
        if predicted == actual
          fold_accuracy[actual] = [fold_accuracy[actual][0] + 1,
                                   fold_accuracy[actual][1] + 1]
        else
          fold_accuracy[actual] = [fold_accuracy[actual][0],
                                   fold_accuracy[actual][1] + 1]
        end
      end

      # print accuracies for each class in this fold
      puts "============= fold#{i+1} ============="
      fold_accuracy.sort.each do |k,v|
        puts "#{k}: %#{((v[0] / v[1].to_f) * 100).round(2)}"
      end

      # print total combined accuracy for this fold
      total_fold_accuracy = fold_accuracy.inject([0,0]) do |acc, (k,v)|
        acc = [acc[0] + v[0], acc[1] + v[1]]
      end
      puts "overall accuracy: %#{((total_fold_accuracy[0] /
                                   total_fold_accuracy[1].to_f) * 100).round(2)}"

      # move fold back into training data
      @training_data[i] = @test_data.delete(i)
    end

    puts ""
    puts "========== final results ========="

    # average the accuracies by class
    average_accuracies = Hash.new([0,0])
    fold_accuracies.each do |fold_accuracy|
      fold_accuracy.inject(average_accuracies) do |acc, (k,v)|
        acc[k] = [acc[k][0] + v[0], acc[k][1] + v[1]]
        acc
      end
    end

    # print average accuracies by class
    average_accuracies.sort.each do |k,v|
      puts "#{k}: %#{((v[0] / v[1].to_f) * 100).round(2)}"
    end

    # average the overall accuracy
    total_accuracy = average_accuracies.inject([0,0]) do |acc, (k,v)|
      acc = [acc[0] + v[0], acc[1] + v[1]]
    end
    puts "overall accuracy: %#{((total_accuracy[0] /
                                 total_accuracy[1].to_f) * 100).round(2)}"
  end

  def classify(el)
    probabilities = {}

    @training_data_array.each do |row|
      row_class = row.last
      row = Utils::remove_last_element(row)

      probabilities[row_class] = (prob_of_row_given_class(row, row_class)
                                  * prob_of_class(row_class))
    end

    @klasses.each do |klass|
    end
    scores.sort {|a,b| b[1] <=> a[1]}[0]
  end

  def prob_of_row_given_class(row, klass)
    row.each do |item|
      prob_of_item
    end
  end

  # P(Class)
  def prob_of_class(klass)
    @class_count[klass] / @total_items.to_f
  end

  # calculate the probability density for a given attribute based on a class,
  # represented as a value {v} and a position in the data array
  def probability_density(v, pos, klass)
    # focus on instances in current dataset of the given class
    data_by_klass = @test_data_array.select{ |row| row.last == klass }

    # focus on specific data item (column) to the given attribute
    data_for_attr = data_by_klass.inject([]) { |acc, e| acc << e[1] }

    mean = Utils::mean(data_for_attr)
    std_dev = Utils::standard_deviation(data_for_attr)

    exponent = -(((v - mean)**2) / (2 * (std_dev**2)).to_f)
    main_exp = (1 / (std_dev * Math.sqrt(2 * Math::PI))) * Math::E
    main_exp**exponent
  end

end

