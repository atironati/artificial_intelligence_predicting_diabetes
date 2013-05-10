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
    sum = a.inject(0){|accum, i| accum + (i.to_f-m)**2 }
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
      #puts "REMOVING INDICES: #{a_indices_to_remove}"
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

  #def self.parse_arguments()
    #ARGV.each do |arg|
      ## 10 fold option here
      #if arg == "-v" || arg == "--verbose"
        ##verbose_mode = true
      #else
        ##file = File.open(arg, "r")
      #end
    #end
  #end

  # write folds to pima-folds.csv for inspection
  def self.write_folds(folds)
    CSV.open("data/pima-folds.csv", "wb") do |csv|
      (0..9).each do |i|
        csv << ["fold#{i+1}"]
        # csv << ["num elements: #{folds[i].size}"]
        # class_count = folds[i].inject(Hash.new(0)) { |h,v| h[v.last] += 1; h }
        #csv << ["class_count: #{class_count}"]
        folds[i].each do |row|
          csv << row
        end
        csv << []
      end
    end
  end

  # creates 10 stratified folds for the data in the given array,
  # formated as a hash with numbered keys pointing to each fold
  # {a}           is an array containing the relevant data
  # {class_count} is a hash containing the count of the
  #               total occurences of each class in {a}
  # {fold_size}   is the size of each respective fold
  # {total}       is a convenient representation of the size of {a}
  def self.create_stratified_folds(a, class_count, fold_size, total)
    # randomize data
    a = a.shuffle

    # determine how many instances of each class should be in each fold
    number_per_fold = Hash[class_count.map do |k,v|
      new_val = (v * (fold_size.to_f / total.to_f)).round
      [k, new_val]
    end ]

    folds = Hash.new([])
    remaining_total = total
    reached_the_end = false

    # for each fold, satisfy number_per_fold criteria
    # as best as possible for each class
    (0..9).each do |i|
      # determine how many slots we have to fill
      remaining_to_fill = fold_size
      if remaining_total <= fold_size
        reached_the_end = true
        remaining_to_fill = remaining_total
      end

      # fulfill number_per_fold requirements for each class
      # if we've reached the end, just move everything over
      fold = []
      unless reached_the_end
        # find n examples of each class for this fold
        number_per_fold.each do |k,n|
          n.times do
            # search array for matching class, remove associated row,
            # and store in new collection for this fold
            fold << a.delete_at(a.find_index { |row| row.last == k })
          end
        end
        folds[i] = fold
      else
        folds[i] = a
      end

      # decrement counters
      remaining_total -= fold_size
    end

    # save folds to file for inspection
    write_folds(folds)

    folds
  end

  # parses the pima csv file, skipping the header row
  def self.parse_csv(filename = 'pima')
    items = []
    count = 0
    first = true
    class_count = Hash.new(0)

    CSV.foreach("data/#{filename}.csv") do |row|
      unless first
        new_row = []
        row.each_with_index do |item, i|
          new_row[i] = item
        end

        items[count] = new_row

        class_count[new_row.last] += 1
        count += 1
      end
      first = false
    end

    fold_size = (count / 10.0).round

    create_stratified_folds(items, class_count, fold_size, count)
  end

end
