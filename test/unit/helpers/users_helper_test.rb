require 'test_helper'

class UsersHelperTest < ActionView::TestCase

	setup do
		@user = Factory(:john)
	end

	# gravatar_for

	test "gravatar_for: default size" do
		regex = /<img[^>]+src="http:\/\/gravatar.com\/avatar\/[\d\w]+.png\?s=50"\s\/>/

		assert_match regex, gravatar_for(@user)
	end

	test "gravatar_for: custom size" do
		custom_size = 140

		regex = /<img[^>]+src="http:\/\/gravatar.com\/avatar\/[\d\w]+.png\?s=#{custom_size}"\s\/>/o

		assert_match regex, gravatar_for(@user, size: custom_size)
	end
end
