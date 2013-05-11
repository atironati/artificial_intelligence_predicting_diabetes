#!/usr/bin/env ruby
require './utils'

class KNearestNeighbor
  def initialize(k = 4)
    @training_data = Utils::parse_csv
    @test_data = Hash.new([])
    @k = k
    report()
  end

  # classify and report on accuracy of classification
  # using 10-fold stratified cross-validation
  def report()
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
    fold_accuracies = Array.new(10) { Hash.new([0,0]) }

    fold_accuracies.each_with_index do |fold_accuracy, i|
      # move current fold out of training data and into test data
      @test_data[i] = @training_data.delete(i)

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

  # classify given instance based on k nearest numbers
  def classify(to_classify)
    closest = nearest_neighbours(to_classify)

    # create hash counting occurrences of each value
    freq = closest.inject(Hash.new(0)) { |h,v| h[v[1].last] += 1; h }
    # sort to find closest neighbors
    freq = freq.sort_by { |v| freq[v] }
    #puts "freq: #{freq}"
    # filter out values that aren't the most common (possibly equal) values
    freq = freq.inject([]) do |acc,e|
      last_element = acc.last
      last_count = (last_element ? last_element[1] : 0)
      last_count > e[1] ? acc : acc << e
    end

    # randomly choose out of the top equal values
    #puts "freq: #{freq}"
    freq[Random.rand(freq.length)][0]
  end

  # find the nearest neighbors to a given instance
  def nearest_neighbours(to_classify)
    find_closest_data(to_classify, true)
  end

  private

  # finds the k closest data points to to_classify based on euclidean distance
  # return format - an array with each element formatted as follows:
  # [ distance_from_to_classify, row, row_class ]
  def find_closest_data(to_classify, remove_last_el)
    calculated_distances = {}
    to_classify = Utils::remove_last_element(to_classify) if remove_last_el

    # store indices correlated to missing values for use in discounting
    # those fields in the values we are comparing, then remove them
    tc_indices_to_remove = Utils::indices_to_remove(to_classify)
    to_classify = Utils::remove_indices_from(to_classify, tc_indices_to_remove)

    # iterate through each of the folds in the training data
    @training_data.each do |fold,rows|
      # iterate through each row in the current fold
      rows.each_with_index do |row, index|
        row_class = row.last
        row = Utils::remove_last_element(row)

        row = Utils::remove_indices_from(row, tc_indices_to_remove)

        # now that we have removed elements based on the missing values in
        # to_classify, we must do the same based on the missing values in row
        # make local copy of to_classify so elements aren't permanently deleted
        local_tc = to_classify.dup
        row_indices_to_remove = Utils::indices_to_remove(row)
        row,local_tc = *Utils::cleanse_missing_values(row,local_tc,
                                                      row_indices_to_remove)

        # with both arrays appropriately cleansed, we can now calculate distance
        if local_tc.size > 0 && row.size > 0 && local_tc.size == row.size
          distance = Utils::euclidean_distance(local_tc, row)
          calculated_distances[index] = [distance, row, row_class]
        end
      end
    end

    calculated_distances.sort {|x, y| x[1][0] <=> y[1][0]}.first(@k)
  end
end

knn = KNearestNeighbor.new
