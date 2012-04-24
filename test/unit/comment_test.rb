require 'test_helper'

class CommentTest < ActiveSupport::TestCase
  CONTENT_VALID = "foo bar"

  test "comment should have content" do
  	user = users(:john)
  	discussion = discussions(:one)

    comment = discussion.comments.build
    comment.user_id = user.id

  	assert comment.invalid?

  	comment.content = CONTENT_VALID

  	assert comment.valid?
  end

  test "comment should have discussion_id" do
  	user = users(:john)

  	comment = Comment.new content: CONTENT_VALID
  	comment.user_id = user.id

  	assert comment.invalid?
  end

  test "comment should have user_id" do
    discussion = discussions(:one)
    user = users(:john)

    comment = discussion.comments.build content: CONTENT_VALID
 
  	assert comment.invalid?

  	comment.user_id = user.id

  	assert comment.valid?
  end
end
