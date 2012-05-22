require 'test_helper'

class CommentTest < ActiveSupport::TestCase
  CONTENT_VALID = "foo bar"
  
  setup do
    @john = users(:john)
    @discussion = discussions(:discussion_with_comments)
  end

  test "comment should have content" do
    comment = @discussion.comments.build
    comment.user_id = @john.id

  	assert comment.invalid?

  	comment.content = CONTENT_VALID

  	assert comment.valid?
  end

  test "comment should have discussion_id" do
  	comment = Comment.new content: CONTENT_VALID
  	comment.user_id = @john.id

  	assert comment.invalid?
  end

  test "comment should have user_id" do
    comment = @discussion.comments.build content: CONTENT_VALID
 
  	assert comment.invalid?

  	comment.user_id = @john.id

  	assert comment.valid?
  end
end
