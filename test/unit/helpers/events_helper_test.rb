require 'test_helper'

class EventsHelperTest < ActionView::TestCase
	# format_datetime

	test "format_datetime: display time for this year" do
		regex = /\w+day,\s\w+\s\d{1,2}\s-\s\d{1,2}:\d{1,2}/

		(0..7).each do |delta|
			assert_match regex, format_datetime(delta.days.ago)
		end
	end

	test "format_datetime: display time for previous years" do
		regex = /\w+\s\d{1,2}\s\d{4}\s-\s\d{1,2}:\d{1,2}/
		this_day_in_last_year = 1.year.ago

		(0..7).each do |delta|
			assert_match regex, format_datetime(this_day_in_last_year - delta.days)
		end

	end
end
