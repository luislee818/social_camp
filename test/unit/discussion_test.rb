require 'test_helper'

class DiscussionTest < ActiveSupport::TestCase
  SUBJECT_VALID = "Foo"
  SUBJECT_TOO_LONG = "f" * 51
  CONTENT_VALID = "Lorem Ipsum"
  
  DEFAULT_OPTIONS = {
    subject: SUBJECT_VALID,
    content: CONTENT_VALID
  }
  
  setup do
    @john = users(:john)
    @discussion_with_comments = discussions(:discussion_with_comments)
    @last_comment = comments(:second_comment)
    @discussion_without_comments = discussions(:discussion_without_comments)
  end

  test "discussion should have subject" do
  	discussion = build_discussion_for_user(@john, subject: nil)

  	assert discussion.invalid?
  end

  test "discussion should have content" do
    discussion = build_discussion_for_user(@john, content: nil)

  	assert discussion.invalid?
  end

  test "discussion subject should be less than 50 characters" do
    discussion = build_discussion_for_user(@john, subject: SUBJECT_TOO_LONG)

  	assert discussion.invalid?
  end

  test "discussion should have user_id" do
    discussion = create()

    assert discussion.invalid?
  end
  
  test "display_title should be the same as discussion subject" do
    discussion = create()
    
    assert_equal SUBJECT_VALID, discussion.display_title
  end
  
  test "last_update_content of a discussion without comments should be the same as the content of discussion" do
    assert_equal @discussion_without_comments.content, @discussion_without_comments.last_update_content
  end
  
  test "last_update_content of a discussion with comments should be the same as the content of last comment" do
    assert_equal @last_comment.content, @discussion_with_comments.last_update_content
  end
  
  # TODO: Add tests for last_update_user, last_update_time and touch
  
  private
  
    def create(options = {})
      Discussion.new(DEFAULT_OPTIONS.merge(options))
    end
  
    def build_discussion_for_user(user, options = {})
      user.discussions.build(DEFAULT_OPTIONS.merge(options))
    end
end
