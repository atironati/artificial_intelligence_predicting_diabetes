require 'csv'

module Utils

  def euclidian_distance(a, b, keep_last_a = true, keep_last_b = true)
    a = a[0..-2] unless keep_last_a
    b = b[0..-2] unless keep_last_b

    Math.sqrt(set1.zip(set2).map { |x| (x[1] - x[0])**2 }.reduce(:+))
  end

  # discounts similar values from both arrays if either is missing
  # betermines whether 0s are missing values based on variance of the data
  def self.cleanse_missing_values(a,b)
    a_indices_to_remove = a.each_index.select{|i| arr[i] == 0}

    mean = (ary.inject(0.0) {|s,x| s + x}) / Float(ary.length)
    variance = ary.inject(0.0) {|s,x| s + (x - mean)**2}

    a_indices_to_remove.each do |del|
      a.delete_at(del)
      b.delete_at(del)
    end

    b_indices_to_remove = b.each_index.select{|i| arr[i] == 0}

    b_indices_to_remove.each do |del|
      a.delete_at(del)
      b.delete_at(del)
    end
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
