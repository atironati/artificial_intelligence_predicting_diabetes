#!/usr/bin/env ruby
require './cross_validation'
require './utils'

class NaiveBayes
  attr_accessor :cv
  def initialize(cv)
    @cv = cv
  end

  #P(Class | Row) = P(Row | Class) * P(Class)
  def classify(row)
    probabilities = {}

    row_class = row.last
    row = Utils::remove_last_element(row)

    # P(Row) = P(R1) * P(R2) * ... * P(Rn)
    @cv.classes.each do |clazz|
      # calculate probability density for each element in this row
      prob_of_item_given_class = 1
      row.each_with_index do |item, i|
        prob_of_item_given_class *= probability_density(item, i, clazz)
      end

      probabilities[clazz] = prob_of_item_given_class *
                             prob_of_class(clazz)
    end

    # filter out values that aren't the most probable (possibly equal) values
    most_probable = probabilities.inject([]) do |acc, (k,v)|
      last_element = acc.last
      last_count = (last_element ? last_element[1] : 0)
      if last_count > v
        acc
      elsif last_count == v
        acc << [k,v]
      else
        acc.clear
        acc = [[k,v]]
      end
    end

    # randomly choose out of the top equal probable values
    most_probable[Random.rand(most_probable.length)][0]
  end

  # P(Class)
  def prob_of_class(klass)
    @cv.class_count[klass] / @cv.total_items.to_f
  end

  # calculate the probability density for a given attribute based on a class,
  # represented as a value {v} and a position in the data array
  def probability_density(v, pos, klass)
    # focus on instances in current dataset of the given class
    data_by_klass = @cv.training_data_array.select{ |row| row.last == klass }

    # focus on specific data item (column) to the given attribute
    data_for_attr = data_by_klass.inject([]) { |acc, e| acc << e[1] }

    mean = Utils::mean(data_for_attr)
    std_dev = Utils::standard_deviation(data_for_attr)

    exponent = -(((v.to_f - mean)**2) / (2 * (std_dev**2)).to_f)
    main_exp = (1 / (std_dev * Math.sqrt(2 * Math::PI).to_f)) * Math::E
    main_exp**exponent
  end

end

cv = CrossValidation.new
nb = NaiveBayes.new(cv)
cv.report(nb)
