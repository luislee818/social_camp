require 'test_helper'

class DiscussionTest < ActiveSupport::TestCase
  SUBJECT_VALID = "Foo"
  SUBJECT_TOO_LONG = "f" * 51
  CONTENT_VALID = "Lorem Ipsum"

  test "discussion should have subject" do
    user = users(:john)
  	discussion = user.discussions.build content: CONTENT_VALID

  	assert discussion.invalid?
  end

  test "discussion should have content" do
  	user = users(:john)
    discussion = user.discussions.build subject: SUBJECT_VALID

  	assert discussion.invalid?
  end

  test "discussion subject should be less than 50 characters" do
  	user = users(:john)
    discussion = user.discussions.build subject: SUBJECT_TOO_LONG,
                                content: CONTENT_VALID

  	assert discussion.invalid?
  end

  test "discussion should have user_id" do
    discussion = Discussion.new subject: SUBJECT_VALID,
                                content: CONTENT_VALID

    assert discussion.invalid?
  end
end
