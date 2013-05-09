require 'csv'

module Utils

  # ----------------- variance methods -----------------
  def self.sum(a)
    a.inject(0){|accum, i| accum + i.to_f }
  end

  def self.mean(a)
    sum(a)/a.length.to_f
  end

  def self.sample_variance(a)
    m = mean(a)
    sum = a.inject(0){|accum, i| accum +(i.to_f-m)**2 }
    sum/(a.length - 1).to_f
  end

  def self.standard_deviation(a)
    return Math.sqrt(sample_variance(a))
  end
  # ----------------------------------------------------

  def self.remove_last_element(a)
    a[0..-2]
  end

  # determines whether 0 values should be removed based on
  # threshold between regular variance and cleansed variance
  def self.indices_to_remove(a)
    # variance with possible zero values
    a_variance = standard_deviation(a)

    # remove zero values and find new variance
    a_indices_to_remove = a.each_index.select{|i| a[i].to_f == 0.0}
    a.delete_if.with_index { |_, index| a_indices_to_remove.include? index }
    cleansed_a_variance = standard_deviation(a)

    # remove zeroes if the difference in variances is above 0.05
    if (a_variance - cleansed_a_variance).abs > 0.05
      puts "REMOVING INDICES: #{a_indices_to_remove}"
      return a_indices_to_remove
    end
    []
  end

  # remove elements from the given array based on an array of indices
  def self.remove_indices_from(a, indices)
    a.delete_if.with_index { |_, i| indices.include? i }
  end

  # discounts similar values from both arrays based on given indices
  # returns an array containing both modified arrays
  def self.cleanse_missing_values(a,b,indices)
    [remove_indices_from(a,indices), remove_indices_from(b,indices)]
  end

  # calculate the euclidean distance between two data points
  def self.euclidean_distance(a, b)
    Math.sqrt(a.zip(b).map { |x| (x[1].to_f - x[0].to_f)**2 }.reduce(:+))
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

  # parses the pima csv file, skipping the header row
  def self.parse_csv(filename = 'pima')
    items = []
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
