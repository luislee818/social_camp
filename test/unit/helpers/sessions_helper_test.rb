require 'test_helper'

class SessionsHelperTest < ActionView::TestCase

	setup do
		@john = users(:john)
		@jane = users(:jane)
	end

	# sign_in

	test "sign_in: should set cookie and current_user variable" do
		sign_in @john

		assert_equal @john.id, cookies[:user_id]
		assert_equal @john, current_user
	end

	# sign_out

	test "sign_out: should clear cookie and current_user variable" do
		sign_in @john
		sign_out

		assert_nil cookies[:user_id]
		assert_nil current_user
	end

	# current_user had been covered in tests above

	# signed_in?

	test "signed_in?: true for signed in user" do
		sign_in @john

		assert signed_in?
	end

	test "signed_in?: false for not signed in user" do
		refute signed_in?
	end

	test "signed_in?: false for signed out user" do
		sign_in @john
		sign_out

		refute signed_in?
	end

	# current_user?

	test "current_user?: true for current user" do
		sign_in @john

		assert current_user?(@john)
	end

	test "current_user?: false for non current user" do
		sign_in @john

		refute current_user?(@jane)
	end

	# save_previously_requested_page should be covered in integration tests

	# redirect_to_previously_requested_page_or should be covered in integration tests

	# user_from_recognized_cookie

	test "user_from_recognized_cookie: should recognize user from cookie" do
		cookies[:user_id] = @john.id

		assert_equal @john, user_from_recognized_cookie()
	end

	test "user_from_recognized_cookie: should return nil if cookie not exist" do
		cookies[:user_id] = nil

		assert_nil user_from_recognized_cookie()
	end

	# clear_requested_page should be covered in integration tests
end
