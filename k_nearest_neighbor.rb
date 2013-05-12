#!/usr/bin/env ruby
require './cross_validation'
require './utils'

class KNearestNeighbor
  attr_accessor :cv, :k

  def initialize(cv, k = 5)
    @cv = cv
    @k = k
  end

  # classify given instance based on k nearest numbers
  def classify(to_classify)
    closest = nearest_neighbours(to_classify)

    # create hash counting occurrences of each value
    freq = closest.inject(Hash.new(0)) { |h,v| h[v[1].last] += 1; h }
    # sort to find closest neighbors
    freq = freq.sort_by { |v| freq[v] }

    # filter out values that aren't the most common (possibly equal) values
    freq = freq.inject([]) do |acc,e|
      last_element = acc.last
      last_count = (last_element ? last_element[1] : 0)
      if last_count > e[1]
        acc
      elsif last_count == e[1]
        acc << e
      else
        acc.clear
        acc = [e]
      end
    end

    # randomly choose out of the top equal values
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

    # iterate through each row in the training data
    @cv.training_data_array.each_with_index do |row, index|
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

    calculated_distances.sort {|x, y| x[1][0] <=> y[1][0]}.first(@k)
  end
end

cv = CrossValidation.new
knn = KNearestNeighbor.new(cv)
cv.report(knn)
