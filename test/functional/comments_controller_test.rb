require 'test_helper'

class CommentsControllerTest < ActionController::TestCase

  # Create comment-------------------------------------------------

  test "user should signin before creating comment" do
    make_sure_user_is_not_signed_in
    
    comment_content = "Lorem Ipsum"
    post :create, comment: { content: comment_content }
    
    assert_redirected_to signin_path
  end

  test "comment should not be created when content is not provided" do
    assert_no_difference 'Comment.count' do
      user = users(:john)
      sign_in user

      discussion = discussions(:one)

      post :create, discussion_id: discussion.id, comment: { }
      assert_redirected_to discussion
    end
  end

  test "comment should be created when valid info (content) is provided" do
    user = users(:john)
    sign_in user

    discussion = discussions(:one)

    comment_content = "Lorem Ipsum"
    post :create, discussion_id: discussion.id, comment: { content: comment_content }

    assert_redirected_to discussion

    # TODO: how to reload child assoications? discussion.comments.reload doesn't work
    comment_created = Comment.last

    refute comment_created.nil?
    assert_equal comment_content, comment_created.content
    assert_equal user, comment_created.user
  end

end
