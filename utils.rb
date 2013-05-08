require 'csv'

module Utils

  def self.sum(a)
    a.inject(0){|accum, i| accum + i }
  end

  def self.mean(a)
    sum(a)/a.length.to_f
  end

  def sample_variance(a)
    m = mean(a)
    sum = a.inject(0){|accum, i| accum +(i-m)**2 }
    sum/(a.length - 1).to_f
  end

  def self.standard_deviation(a)
    return Math.sqrt(sample_variance(a))
  end

  def self.remove_last_element(a)
    a[0..-2]
  end

  # determines whether 0 values should be removed based on
  # threshold between regular variance and cleansed variance
  def self.indices_to_remove(a)
    # variance with possible zero values
    a_variance = standard_deviation(a)

    # remove zero values and find new variance
    a_indices_to_remove = a.each_index.select{|i| arr[i] == 0}
    a_indices_to_remove.each{ |del| a.delete_at(del) }
    cleansed_a_variance = standard_deviation(a)

    if (Math.abs( a_variance - cleansed_a_variance ) > 0.05)
      return a_indices_to_remove
    end
    []
  end

  # discounts similar values from both arrays if either is missing
  # betermines whether 0s are missing values based on variance of the data
  def self.cleanse_missing_values(a,b)
    indices_to_remove(a).each do |del|
      a.delete_at(del)
      b.delete_at(del)
    end

    indices_to_remove(b).each do |del|
      a.delete_at(del)
      b.delete_at(del)
    end
    [a,b]
  end

  # calculate the euclidian distance between two data points
  # assumes {a} does not contain a classification
  # assumes {b} does contain a classification and removes it
  def euclidian_distance(a, b)
    b = remove_last_element(b)
    a,b = *cleanse_missing_values(a,b)

    Math.sqrt(a.zip(b).map { |x| (x[1] - x[0])**2 }.reduce(:+))
  end

  def self.parse_arguments()
    ARGV.each do |arg|
      # 10 fold option here
      if arg == "-v" || arg == "--verbose"
        #verbose_mode = true
      else
        #file = File.open(arg, "r")
      end
    end
  end

  def self.parse_csv(filename = 'pima')
    items = {}
    count = 0
    first = true

    CSV.foreach("data/#{filename}.csv") do |row|
      unless first
        new_row = []
        row.each_with_index do |item, i|
          new_row[i] = item
        end
        items[count] = new_row

        count += 1
      end
      first = false
    end
    items
  end

end
