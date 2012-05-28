require 'test_helper'

class CommentsControllerTest < ActionController::TestCase
  CONTENT_VALID = 'Lorem Ipsum'

  DEFAULT_OPTIONS = {
    content: CONTENT_VALID
  }
  
  setup do
    # users
    @john = Factory(:john)
    @jane = Factory(:jane)
    @admin = Factory(:admin)

    # a discussion with comments
    @discussion = Factory(:discussion, user: @john)
    @comment = Factory(:comment, discussion: @discussion, user: @john)
    Factory(:comment, discussion: @discussion, user: @jane)
  end

  # Create comment-------------------------------------------------

  test "user should signin before creating comment" do
    make_sure_user_is_not_signed_in
    
    post :create, comment: DEFAULT_OPTIONS
    
    assert_redirected_to signin_path
  end

  test "comment should not be created when content is not provided" do
    assert_no_difference 'Comment.count' do
      sign_in @john

      post :create, discussion_id: @discussion.id, comment: { }
      assert_redirected_to @discussion
    end
  end

  test "comment should be created when valid info (content) is provided" do
    sign_in @john

    post :create, discussion_id: @discussion.id, comment: DEFAULT_OPTIONS

    assert_redirected_to @discussion

    # TODO: how to reload child assoications? discussion.comments.reload doesn't work
    created_comment = Comment.last

    refute created_comment.nil?
    assert_equal DEFAULT_OPTIONS[:content], created_comment.content
    assert_equal @john, created_comment.user
  end

  test "upon successful comment creation there should be a changelog" do
    sign_in @john

    post :create, discussion_id: @discussion.id, comment: DEFAULT_OPTIONS

    created_comment = Comment.last
    changelog = Changelog.of_trackable(created_comment).last

    assert_equal created_comment, changelog.trackable
    assert_equal ActionType::ADD, changelog.action_type_id
    assert_equal @john.id, changelog.user_id
  end

  test "upon successful comment creation updated_at of discussion should be updated" do
    sign_in @john

    discussion_old_timestamp = @discussion.updated_at

    post :create, discussion_id: @discussion.id, comment: DEFAULT_OPTIONS

    created_comment = Comment.last
    discussion = Discussion.find @discussion.id
    discussion_new_timestamp = discussion.updated_at

    assert discussion_new_timestamp > discussion_old_timestamp
  end

  # Show comment-------------------------------------------------

  test "user should signin before viewing a comment" do
    make_sure_user_is_not_signed_in
    
    get :show, id: @comment.id

    assert_redirected_to signin_path
  end

  test "user should be redirected to discussion when viewing a comment" do
    sign_in @john
    
    get :show, id: @comment.id

    assert_redirected_to @comment.discussion
  end
  
  # Edit comment-------------------------------------------------

  test "user should sign in before viewing edit comment page" do
    make_sure_user_is_not_signed_in

    get :edit, id: @comment.id

    assert_redirected_to signin_path
  end

  test "user cannot view edit page of an comment created by others" do
    sign_in @jane

    get :edit, id: @comment.id

    assert_redirected_to @comment.discussion
  end

  test "user can view edit page of an comment created by herself" do
    sign_in @john

    get :edit, id: @comment.id

    assert_select 'title', 'SocialCamp | Edit comment'
    assert_select 'div#comment-edit', count: 1
    assert_select 'a#discussion-view-link', count: 1
  end

  test "admin can view edit page of an discussion created by others" do
    sign_in @admin

    get :edit, id: @comment.id

    assert_select 'title', 'SocialCamp | Edit comment'
    assert_select 'div#comment-edit', count: 1
    assert_select 'a#discussion-view-link', count: 1
  end
  
  # Update comment-------------------------------------------------

  test "user should sign in before update a comment" do
    make_sure_user_is_not_signed_in

    put :update, id: @comment.id

    assert_redirected_to signin_path
  end

  test "user cannot update a comment created by others" do
    sign_in @jane

    put :update, id: @comment.id

    assert_redirected_to discussions_path
  end

  test "user can update an discussion created by herself" do
    sign_in @john

    updated_content = "More Lorem Ipsum"
    put :update, id: @comment.id, comment: { content: updated_content }

    assert_redirected_to @comment.discussion

    updated_comment = Comment.find @comment.id

    assert_equal updated_content, updated_comment.content
    assert_equal @john.id, updated_comment.user_id
  end

  test "admin can update a comment created by another user" do
    sign_in @admin

    updated_content = "More Lorem Ipsum"
    put :update, id: @comment.id, comment: { content: updated_content }

    assert_redirected_to @comment.discussion

    updated_comment = Comment.find @comment.id

    assert_equal updated_content, updated_comment.content
    assert_not_equal @admin.id, updated_comment.user_id
  end

  test "upon successful comment update there should be a changelog" do
    sign_in @john

    updated_content = "More Lorem Ipsum"
    put :update, id: @comment.id, comment: { content: updated_content }

    assert_redirected_to @comment.discussion

    updated_comment = Comment.find @comment.id
    changelog = Changelog.of_trackable(updated_comment).last

    assert_equal updated_comment, changelog.trackable
    assert_equal ActionType::UPDATE, changelog.action_type_id
    assert_equal @john.id, changelog.user_id
  end

  test "upon successful comment update updated_at of discussion should be updated" do
    sign_in @john

    discussion_old_timestamp = @discussion.updated_at

    updated_content = "More Lorem Ipsum"
    put :update, id: @comment.id, comment: { content: updated_content }

    discussion = Discussion.find @discussion.id
    discussion_new_timestamp = discussion.updated_at

    assert discussion_new_timestamp > discussion_old_timestamp
  end
  
  # Destroy comment-------------------------------------------------

  test "user should sign in before destroying a comment" do
    make_sure_user_is_not_signed_in

    delete :destroy, id: @comment.id

    assert_redirected_to signin_path
  end

  test "user cannot destroy a discussion created by others" do
    sign_in @jane

    delete :destroy, id: @comment.id

    assert_redirected_to discussions_path

    comment_attempted_to_destroy = Comment.find @comment.id

    refute comment_attempted_to_destroy.nil?
  end

  test "user can destroy a comment created by herself" do
    sign_in @john

    delete :destroy, id: @comment.id

    assert_redirected_to @comment.discussion

    comment_attempted_to_destroy = Comment.find_by_id @comment.id

    assert comment_attempted_to_destroy.nil?
  end

  test "admin can destroy a comment created by another user" do
    sign_in @admin

    delete :destroy, id: @comment.id

    assert_redirected_to @comment.discussion

    comment_attempted_to_destroy = Comment.find_by_id @comment.id

    assert comment_attempted_to_destroy.nil?
  end

  test "upon successful comment destroy there should be a changelog" do
    sign_in @john

    final_words = @comment.final_words
    delete :destroy, id: @comment.id

    comment_attempted_to_destroy = Comment.find_by_id @comment.id

    changelog = Changelog.of_trackable(@comment).last

    assert comment_attempted_to_destroy.nil?
    assert_equal final_words, changelog.destroyed_content_summary
    assert_equal ActionType::DESTROY, changelog.action_type_id
    assert_equal @john.id, changelog.user_id
  end

  test "upon successful comment destroy by admin there should be a changelog" do
    sign_in @admin

    final_words = @comment.final_words
    delete :destroy, id: @comment.id

    comment_attempted_to_destroy = Comment.find_by_id @comment.id

    changelog = Changelog.of_trackable(@comment).last

    assert comment_attempted_to_destroy.nil?
    assert_equal final_words, changelog.destroyed_content_summary
    assert_equal ActionType::DESTROY, changelog.action_type_id
    assert_equal @admin.id, changelog.user_id
  end

  test "upon successful comment destroy updated_at of discussion should be updated" do
    sign_in @john

    discussion_old_timestamp = @discussion.updated_at

    delete :destroy, id: @comment.id

    discussion = Discussion.find @discussion.id
    discussion_new_timestamp = discussion.updated_at

    assert discussion_new_timestamp > discussion_old_timestamp
  end

end
