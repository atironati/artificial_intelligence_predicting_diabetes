require './utils'

class CrossValidation
  attr_accessor :training_data, :test_data, :training_data_array,
                :total_items, :class_count, :classes, :fold_accuracies

  def initialize
    @training_data = Utils::parse_csv
    @test_data = Hash.new([])
    @training_data_array = [] # a more convenient way to iterate through the data
    @total_items = 0
    @class_count = Hash.new(0)
    @classes = []

    # create hash representing accuracies for each class in each fold.
    # consists of an array with each element correlated to a fold and
    # representing a collection of accuracies, formatted as follows:
    # [
    #   {
    #     "class0" => [correct_class0_classifications,
    #                  total_class0_classifications],
    #     "class1" => [correct_class1_classifications,
    #                  total_class1_classififications]
    #   },
    #
    #   ...
    #
    #   {
    #     "class0" => [correct_class0_classifications,
    #                  total_class0_classifications],
    #     "class1" => [correct_class1_classifications,
    #                  total_class1_classififications]
    #   }
    # ]
    @fold_accuracies = Array.new(10) { Hash.new([0,0]) }
  end

  # classify and report on accuracy of classification
  # using 10-fold stratified cross-validation
  def report(algorithm)
    @fold_accuracies.each_with_index do |fold_accuracy, i|
      # move current fold out of training data and into test data
      @test_data[i] = @training_data.delete(i)

      @training_data_array = []
      # flatten out folds into one large array, for convenience
      @training_data.each do |fold,rows|
        rows.each do |row|
          @training_data_array << row
        end
      end

      @class_count = @training_data_array.inject(Hash.new(0)) { |h,v| h[v.last] += 1; h }
      @classes = @class_count.inject([]) { |acc, (k,v)| acc << k }
      @total_items = @training_data_array.size

      # classify each row in the fold
      @test_data[i].each do |row|
        predicted = algorithm.classify(row)
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

      print_results(fold_accuracy, i)

      # move fold back into training data
      @training_data[i] = test_data.delete(i)
    end

    print_final_results
  end

  # print the accuracy results for a particular fold
  def print_results(fold_accuracy, i)
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
  end

  # print the average accuracy across all 10 folds
  def print_final_results
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
      puts "avg. #{k}: %#{((v[0] / v[1].to_f) * 100).round(2)}"
    end

    # average the overall accuracy
    total_accuracy = average_accuracies.inject([0,0]) do |acc, (k,v)|
      acc = [acc[0] + v[0], acc[1] + v[1]]
    end
    puts "avg. overall accuracy: %#{((total_accuracy[0] /
                                      total_accuracy[1].to_f) * 100).round(2)}"
  end
end
