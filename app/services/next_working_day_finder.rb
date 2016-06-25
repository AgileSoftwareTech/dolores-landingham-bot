require "business_time"

class NextWorkingDayFinder

  attr_reader :date

  def self.run(date = Time.today)
    self.new(date).run
  end

  def initialize(date = Time.today)
    @date = date
  end

  def run
    @date = @date + 1.day until @date.workday?
    @date
  end

end
