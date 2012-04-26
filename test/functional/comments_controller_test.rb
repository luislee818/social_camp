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
    created_comment = Comment.last

    refute created_comment.nil?
    assert_equal comment_content, created_comment.content
    assert_equal user, created_comment.user
  end

  test "upon successful comment creation there should be a changelog" do
    user = users(:john)
    sign_in user

    discussion = discussions(:one)

    comment_content = "Lorem Ipsum"
    post :create, discussion_id: discussion.id, comment: { content: comment_content }

    created_comment = Comment.last
    changelog = Changelog.of_trackable(created_comment).last

    assert_equal created_comment, changelog.trackable
    assert_equal ActionType::ADD, changelog.action_type_id
    assert_equal user.id, changelog.user_id
  end

  test "upon successful comment creation updated_at of discussion should be updated" do
    user = users(:john)
    sign_in user

    discussion = discussions(:one)
    discussion_old_timestamp = discussion.updated_at

    comment_content = "Lorem Ipsum"

    post :create, discussion_id: discussion.id, comment: { content: comment_content }

    created_comment = Comment.last
    discussion.reload
    discussion_new_timestamp = discussion.updated_at

    assert discussion_new_timestamp > discussion_old_timestamp
  end

  # Show comment-------------------------------------------------

  test "user should signin before viewing a comment" do
    make_sure_user_is_not_signed_in
    
    comment = comments(:one)
    get :show, id: comment.id

    assert_redirected_to signin_path
  end

  test "user should be redirected to discussion when viewing a comment" do
    user = users(:jane)
    sign_in user
    
    comment = comments(:one)
    get :show, id: comment.id

    assert_redirected_to comment.discussion
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

  test "upon successful comment update there should be a changelog" do
    user = users(:john)
    sign_in user

    comment = comments(:one) # comment created by John
    updated_content = "Lorem Ipsum"
    put :update, id: comment.id, comment: { content: updated_content }

    assert_redirected_to comment.discussion

    updated_comment = Comment.find comment.id
    changelog = Changelog.of_trackable(updated_comment).last

    assert_equal updated_comment, changelog.trackable
    assert_equal ActionType::UPDATE, changelog.action_type_id
    assert_equal user.id, changelog.user_id
  end

  test "upon successful comment update updated_at of discussion should be updated" do
    user = users(:john)
    sign_in user

    discussion = discussions(:one)
    discussion_old_timestamp = discussion.updated_at

    comment = comments(:one) # comment created by John
    updated_content = "Lorem Ipsum"
    put :update, id: comment.id, comment: { content: updated_content }

    discussion.reload
    discussion_new_timestamp = discussion.updated_at

    assert discussion_new_timestamp > discussion_old_timestamp
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

  test "upon successful comment destroy there should be a changelog" do
    user = users(:john)
    sign_in user

    comment = comments(:one) # comment created by john
    final_words = comment.final_words
    delete :destroy, id: comment.id

    comment_attempted_to_destroy = Comment.find_by_id comment.id

    changelog = Changelog.of_trackable(comment).last

    assert comment_attempted_to_destroy.nil?
    assert_equal final_words, changelog.destroyed_content_summary
    assert_equal ActionType::DESTROY, changelog.action_type_id
    assert_equal user.id, changelog.user_id
  end

  test "upon successful comment destroy by admin there should be a changelog" do
    admin = users(:admin)
    sign_in admin

    comment = comments(:one) # comment created by john
    final_words = comment.final_words
    delete :destroy, id: comment.id

    comment_attempted_to_destroy = Comment.find_by_id comment.id

    changelog = Changelog.of_trackable(comment).last

    assert comment_attempted_to_destroy.nil?
    assert_equal final_words, changelog.destroyed_content_summary
    assert_equal ActionType::DESTROY, changelog.action_type_id
    assert_equal admin.id, changelog.user_id
  end

  test "upon successful comment destroy updated_at of discussion should be updated" do
    user = users(:john)
    sign_in user

    discussion = discussions(:one)
    discussion_old_timestamp = discussion.updated_at

    comment = comments(:one) # comment created by John
    delete :destroy, id: comment.id

    discussion.reload
    discussion_new_timestamp = discussion.updated_at

    assert discussion_new_timestamp > discussion_old_timestamp
  end

end
