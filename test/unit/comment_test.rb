require 'test_helper'

class CommentTest < ActiveSupport::TestCase
  CONTENT_VALID = "foo bar"

  DEFAULT_OPTIONS = {
    content: CONTENT_VALID
  }
  
  setup do
    # users
    @john = Factory(:john)

    # a discussion with comments
    @discussion = Factory(:discussion, user: @john)
    Factory(:comment, discussion: @discussion, user: @john)
    Factory(:comment, discussion: @discussion, user: @john)
  end

  # validations

  test "comment should have content" do
    comment = build_event_for_discussion(@discussion, content: nil)
    comment.user_id = @john.id

  	assert comment.invalid?

  	comment.content = CONTENT_VALID

  	assert comment.valid?
  end

  test "comment should have discussion_id" do
  	comment = create()
  	comment.user_id = @john.id

  	assert comment.invalid?
  end

  test "comment should have user_id" do
    comment = build_event_for_discussion(@discussion)
 
  	assert comment.invalid?

  	comment.user_id = @john.id

  	assert comment.valid?
  end

    # display_title
  
  test "display_title should be the same as comment content" do
    comment = create()
    
    assert_equal CONTENT_VALID, comment.content
  end

    private
  
    def create(options = {})
      Comment.new(DEFAULT_OPTIONS.merge(options))
    end
  
    def build_event_for_discussion(discussion, options = {})
      discussion.comments.build(DEFAULT_OPTIONS.merge(options))
    end

end
