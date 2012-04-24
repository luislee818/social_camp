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
  
  # Edit comment-------------------------------------------------
  test "user should login before viewing edit comment page" do
    make_sure_user_is_not_signed_in
    comment = comments(:one)
    get :edit, id: comment.id

    assert_redirected_to signin_path
  end

  test "user cannot view edit page of an comment created by others" do
    user = users(:jane)
    sign_in user

    comment = comments(:one) # comment created by John
    get :edit, id: comment.id

    assert_redirected_to comment.discussion
  end

  test "user can view edit page of an comment created by herself" do
    user = users(:john)
    sign_in user

    comment = comments(:one) # comment created by John
    get :edit, id: comment.id

    assert_select 'title', 'SocialCamp | Edit comment'
  end

  test "admin can view edit page of an discussion created by others" do
    admin = users(:admin)
    sign_in admin

    comment = comments(:one) # comment created by John
    get :edit, id: comment.id

    assert_select 'title', 'SocialCamp | Edit comment'
  end
  
  # Update comment-------------------------------------------------
  test "user should login before update a comment" do
    make_sure_user_is_not_signed_in
    comment = comments(:one)
    put :update, id: comment.id

    assert_redirected_to signin_path
  end

  test "user cannot update a comment created by others" do
    user = users(:jane)
    sign_in user

    comment = comments(:one) # comment created by John
    put :update, id: comment.id

    assert_redirected_to discussions_path
  end

  test "user can update an discussion created by herself" do
    user = users(:john)
    sign_in user

    comment = comments(:one) # comment created by John
    updated_content = "Lorem Ipsum"
    put :update, id: comment.id, comment: { content: updated_content }

    assert_redirected_to comment.discussion

    updated_comment = Comment.find comment.id

    assert_equal updated_content, updated_comment.content
    assert_equal user.id, updated_comment.user_id
  end

  test "admin can update a comment created by another user" do
    admin = users(:admin)
    sign_in admin

    comment = comments(:one) # comment created by John
    updated_content = "Lorem Ipsum"
    put :update, id: comment.id, comment: { content: updated_content }

    assert_redirected_to comment.discussion

    updated_comment = Comment.find comment.id

    assert_equal updated_content, updated_comment.content
    assert_not_equal admin.id, updated_comment.user_id
  end
  
  # Destroy comment-------------------------------------------------
  test "user should login before destroy a comment" do
    make_sure_user_is_not_signed_in
    comment = comments(:one)
    delete :destroy, id: comment.id

    assert_redirected_to signin_path
  end

  test "user cannot destroy a discussion created by others" do
    user = users(:jane)
    sign_in user

    comment = comments(:one) # comment created by john
    delete :destroy, id: comment.id

    assert_redirected_to discussions_path

    comment_attempted_to_destroy = Comment.find comment.id

    refute comment_attempted_to_destroy.nil?
  end

  test "user can destroy a comment created by herself" do
    user = users(:john)
    sign_in user

    comment = comments(:one) # comment created by john
    delete :destroy, id: comment.id

    assert_redirected_to comment.discussion

    comment_attempted_to_destroy = Comment.find_by_id comment.id

    assert comment_attempted_to_destroy.nil?
  end

  test "admin can destroy a comment created by another user" do
    admin = users(:admin)
    sign_in admin

    comment = comments(:one) # comment created by john
    delete :destroy, id: comment.id

    assert_redirected_to comment.discussion

    comment_attempted_to_destroy = Comment.find_by_id comment.id

    assert comment_attempted_to_destroy.nil?
  end

end
