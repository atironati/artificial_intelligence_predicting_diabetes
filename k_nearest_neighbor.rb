#!/usr/bin/env ruby
require './utils'

class KNearestNeighbor
  def initialize()
    @data = Utils::parse_csv
    report()
  end

  # classify and report on accuracy of classification if applicable
  def report(k=4, to_classify = nil)
    classification = classify(k, to_classify)
    puts "predicted classification: #{classification}"
  end

  # classify given instance basedo on k nearest numbers
  def classify(k=4, to_classify = nil)
    rand_num = Random.rand(@data.length)
    to_classify = to_classify || @data[rand_num]
    closest = nearest_neighbours(k, to_classify)

    # create array counting occurrences of each value
    freq = closest.inject(Hash.new(0)) { |h,v| h[v[1].last] += 1; h }
    # sort to find closest neighbors
    freq = freq.sort_by { |v| freq[v] }
    # filter out values that aren't the most common (possibly equal) values
    freq = freq.inject([]){ |acc,i| acc.last == i ? acc : acc << i }
    # randomly choose out of the top equal values
    freq[Random.rand(freq.length)]
  end

  # find the nearest neighbors to a given instance
  def nearest_neighbours(k=4, to_classify = nil)
    rand_num = Random.rand(@data.length)
    to_classify = to_classify || @data[rand_num]
    find_closest_data(k, to_classify)
  end

  private

  def find_closest_data(k, to_classify)
    calculated_distances = {}

    @data.each_with_index do |row, index|
      distance = Utils::euclidian_distance(to_classify, row, false, true)
      calculated_distances[index] = [distance, row]
    end

    calculated_distances.sort {|x, y| x[0] <=> y[0]}.first(k)
  end
end

knn = KNearestNeighbor.new
