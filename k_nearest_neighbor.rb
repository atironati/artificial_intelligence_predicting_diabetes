#!/usr/bin/env ruby
require './utils'

class KNearestNeighbor
  def initialize()
    @data = Utils::parse_csv
    report()
  end

  # classify and report on accuracy of classification if applicable
  def report(k=4, to_classify = nil)
    rand_num = Random.rand(@data.length)
    to_classify = to_classify || @data[rand_num]
    classification = classify(k, to_classify)
    puts "predicted classification: #{classification}"
    puts "actual classification: #{to_classify.last}"
  end

  # classify given instance based on k nearest numbers
  def classify(k=4, to_classify)
    closest = nearest_neighbours(k, to_classify)

    puts "closest: #{closest}"
    # create array counting occurrences of each value
    freq = closest.inject(Hash.new(0)) { |h,v| puts h[v[1].last] += 1; h }
    # sort to find closest neighbors
    freq = freq.sort_by { |v| freq[v] }
    puts "freq: #{freq}"
    # filter out values that aren't the most common (possibly equal) values
    freq = freq.inject([]) do |acc,e|
      last_element = acc.last
      last_count = (last_element ? last_element[1] : 0)
      last_count > e[1] ? acc : acc << e
    end

    # randomly choose out of the top equal values
    puts "freq: #{freq}"
    freq[Random.rand(freq.length)][0]
  end

  # find the nearest neighbors to a given instance
  def nearest_neighbours(k=4, to_classify = nil)
    rand_num = Random.rand(@data.length)
    to_classify = to_classify || @data[rand_num]

    find_closest_data(k, to_classify, true)
  end

  private

  #
  # return format - an array with each element formatted as follows:
  # [ distance_from_to_classify, row, row_class ]
  def find_closest_data(k, to_classify, remove_last_el)
    calculated_distances = {}
    to_classify = Utils::remove_last_element(to_classify) if remove_last_el

    # store indices correlated to missing values for use in discounting
    # those fields in the values we are comparing, then remove them
    tc_indices_to_remove = Utils::indices_to_remove(to_classify)
    to_classify = Utils::remove_indices_from(to_classify, tc_indices_to_remove)

    @data.each_with_index do |row, index|
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
      distance = Utils::euclidean_distance(local_tc, row)
      calculated_distances[index] = [distance, row, row_class]
    end

    calculated_distances.sort {|x, y| x[1][0] <=> y[1][0]}.first(k)
  end
end

knn = KNearestNeighbor.new
