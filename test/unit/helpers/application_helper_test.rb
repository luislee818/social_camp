require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
	include ERB::Util

	setup do
		@now = Time.now
		@this_time_tomorrow = Time.now + 1.day
		@this_time_yesterday = Time.now - 1.day
	end

	# full_title

	test "full_title: default full title when no page_title provided" do
		assert_equal 'SocialCamp', full_title(nil)
		assert_equal 'SocialCamp', full_title('')
	end

	test "full_title: full title when page_title provided" do
		assert_equal 'SocialCamp | Custom Page', full_title('Custom Page')
	end

	# date_is_today

	test "date_is_today: true when date is today" do
		assert date_is_today(@now)
	end

	test "date_is_today: false when date is not today" do
		refute date_is_today(@this_time_tomorrow)
		refute date_is_today(@this_time_yesterday)
	end

	# date_is_tomorrow

	test "date_is_tomorrow: true when date is tomorrow" do
		assert date_is_tomorrow(@this_time_tomorrow)
	end

	test "date_is_tomorrow: false when date is not tomorrow" do
		refute date_is_tomorrow(@now)
		refute date_is_tomorrow(@this_time_yesterday)
	end

	# date_is_yesterday

	test "date_is_yesterday: true when date is yesterday" do
		assert date_is_yesterday(@this_time_yesterday)
	end

	test "date_is_yesterday: false when date is not yesterday" do
		refute date_is_yesterday(@now)
		refute date_is_yesterday(@this_time_tomorrow)
	end

	# strong

	test "strong: return html_safe string" do
		content = "foo bar"

		output = strong(content)

		assert_equal '<strong>foo bar</strong>', output
		assert output.html_safe?
	end

	test "strong: should html escape string" do
		content = "<script>alert('I steal cookies')</script>"

		output = strong(content)

		assert_equal "<strong>#{h content}</strong>", output
		assert output.html_safe?
	end
end