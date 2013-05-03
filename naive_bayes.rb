class NaiveBayes 
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

