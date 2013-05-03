#!/usr/bin/env ruby

class Bank
  attr_accessor :short_request_tellers, :long_request_tellers, :customers, :time_in_day

  def initialize t, c
    @short_request_tellers = []
    @long_request_tellers = []
    @customers = c
    @time_in_day = 24 * 60 * 60
  end

  # operate the bank
  def operate

  end

  private

  # assign the next customer in line to the best available teller
  def assign_customer customer
    if customer.short_request
      short_request_tellers.each do |teller|

      end
    else
      long_request_tellers.each do |teller|

      end
    end
  end
end


words_hash = {}
file = nil
verbose_mode = false
count = 0

# parse arguments
ARGV.each do |arg|
  if arg == "-v" || arg == "--verbose"
    verbose_mode = true
  else
    file = File.open(arg, "r")
  end
end

# start timing
start_time = Time.now

# sort the characters in a word alphabetically, ignoring case
# Ex. sort_letters( "tomato" ) -> "amoott"
def sort_letters(word)
  word.chars.sort{ |a, b| a.casecmp(b) }.join
end

# loop through each word in the file
while (word = file.gets)
  letters = sort_letters(word)
  hash_entry = words_hash[letters]

  if hash_entry
    # If the key is a first-time match, we have 2 new anagrams
    # otherwise, we are adding only 1 new anagram
    count += hash_entry[0] ? 1 : 2
    words_hash[letters] = [true, hash_entry[1] << word.strip]
  else
    words_hash[letters] = [false, [word.strip]]
  end
end
file.close

# stop timing
end_time = Time.now

# loop through the words_hash and print groups of elements
if verbose_mode
  words_hash.each do |key, value|
    if value[0]
      value[1].each_with_index do |word, index|
        last_word = index == value[1].length - 1
        print last_word ? "#{word}\n" :  "#{word},"
      end
    end
  end
  puts "\n"
end

puts "time: #{end_time - start_time}s"
puts "count: " + count.to_s

