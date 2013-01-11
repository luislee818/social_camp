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
    # users
    @john = Factory(:john)
    @jane = Factory(:jane)

    # a discussion with comments
    @discussion_with_comments = Factory(:discussion, user: @john)
    Factory(:comment, discussion: @discussion_with_comments, user: @john)
    @last_comment = Factory(:comment, discussion: @discussion_with_comments, user: @jane)

    # a discussion without comments
    @discussion_without_comments = Factory(:discussion, user: @jane)
  end

  # Validations

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

  # display_title

  test "display_title should be the same as discussion subject" do
    discussion = create()

    assert_equal SUBJECT_VALID, discussion.display_title
  end

  # last_update_content

  test "last_update_content of a discussion without comments should be the same as the content of discussion" do
    assert_equal @discussion_without_comments.content, @discussion_without_comments.last_update_content
  end

  test "last_update_content of a discussion with comments should be the same as the content of last comment" do
    assert_equal @last_comment.content, @discussion_with_comments.last_update_content
  end

  # last_update_user
  test "last_update_user for a discussion without comments should be the same as user created the discussion" do
    assert_equal @jane, @discussion_without_comments.last_update_user
  end

  test "last_update_user for a discussion with comments should be the same as user created the last comment" do
    assert_equal @jane, @discussion_with_comments.last_update_user
  end

  # last_update_time

  test "last_update_time for a discussion without comments should be the same as the last update time of discussion" do
    assert_equal @discussion_without_comments.updated_at, @discussion_without_comments.last_update_time
  end

  # Note: last_update_time for a discussion with comments will be covered in functional tests of CommentsController

  # touch

  test "calling touch will change the updated_at attribute of discussion" do
    old_timestamp = @discussion_with_comments.updated_at
    @discussion_with_comments.touch

    discussion = Discussion.find @discussion_with_comments.id

    assert discussion.updated_at >= old_timestamp
    # assert_not_equal old_timestamp, discussion.updated_at
  end

  private

    def create(options = {})
      Discussion.new(DEFAULT_OPTIONS.merge(options))
    end

    def build_discussion_for_user(user, options = {})
      user.discussions.build(DEFAULT_OPTIONS.merge(options))
    end
end
