require "rails_helper"
require "business_time"

# I really hate putting this test here as it does not correspond
# to a service object, but I didn't want to make a new folder for
# this odd kind of integration test.  This test is strictly speaking
# not necessary (redundant), and probably kind of brittle, but if you need 
# a little reassurance that things are all working together, this is helpful,
# and much faster than doing it in a feature scenario.  cheers

describe "Quarterly Message Integration" do

  it "sends a message to employees from every time zone as the correct day comes past" do
    Timecop.freeze(day_before_quarterly_messages)
    quarterly_message = create(:scheduled_message, message_time_frame: :quarterly)
    create_employees_from_all_time_zones

    simulate_64_hours_of_daily_message_sending

    verify_that_all_employees_got_the_message(quarterly_message)
  end

  #test helpers

  def verify_that_all_employees_got_the_message(quarterly_message)
    Employee.all.each do |employee|
      expect(SentScheduledMessage.
             where(employee: employee, scheduled_message: quarterly_message)).not_to be_empty
    end
  end

  def simulate_64_hours_of_daily_message_sending
    64.times do
      fast_forward_one_hour
      DailyMessageSender.new.run
    end
  end

  def fast_forward_one_hour
    Timecop.freeze(Time.now + 1.hour)
  end

  def day_before_quarterly_messages
    Time.parse("2015-3-31 00:00:00 UTC")
  end

  def create_employees_from_all_time_zones
    (-11..13).each do |zone|
      create(:employee, time_zone: time_zone_from_offset(zone))
    end
  end

  def time_zone_from_offset(offset)
    ActiveSupport::TimeZone.new(offset).name
  end

end
