require 'test_helper'

class DiscussionsControllerTest < ActionController::TestCase
  setup do
    @discussion = discussions(:one)
  end

  # Create discussion-------------------------------------------------

  test "user should signin before visiting create discussion page" do
    make_sure_user_is_not_signed_in
    get :new
    assert_redirected_to signin_path
  end

  test "new discussion page title should be 'SocialCamp | Create new discussion'" do
    user = users(:john)
    sign_in user
    get :new
    assert_select 'title', 'SocialCamp | Create new discussion'
  end

  test "user should signin before creating discussion" do
    make_sure_user_is_not_signed_in
    
    discussion_subject = "Lorem Ipsum"
    discussion_content = "More Lorem Ipsum"
    post :create, discussion: { subject: discussion_subject, content: discussion_content }
    
    assert_redirected_to signin_path
  end

  test "discussion should not be created when subject is not provided" do
    user = users(:john)
    sign_in user

    post :create, discussion: { content: "Lorem Ipsum" }
    assert_template 'new'
  end

  test "discussion should not be created when content is not provided" do
    user = users(:john)
    sign_in user

    post :create, discussion: { subject: "Lorem Ipsum" }
    assert_template 'new'
  end

  test "discussion should be created when valid info (subject and content) is provided" do
    user = users(:john)
    sign_in user

    discussion_subject = "Lorem Ipsum"
    discussion_content = "More Lorem Ipsum"
    post :create, discussion: { subject: discussion_subject, content: discussion_content }

    assert_redirected_to discussions_path

    created_discussion = Discussion.find_by_subject discussion_subject

    refute created_discussion.nil?
    assert_equal discussion_content, created_discussion.content
    assert_equal user, created_discussion.user
  end

  test "upon successful discussion creation there should be a changelog" do
    user = users(:john)
    sign_in user

    discussion_subject = "Lorem Ipsum"
    discussion_content = "More Lorem Ipsum"
    post :create, discussion: { subject: discussion_subject, content: discussion_content }

    created_discussion = Discussion.find_by_subject discussion_subject
    changelog = Changelog.last

    assert_equal created_discussion, changelog.trackable
    assert_equal ActionType::ADD, changelog.action_type_id
    assert_equal user.id, changelog.user_id
  end

   # Show discussions-------------------------------------------------
  test "user should login before viewing discussions" do
    make_sure_user_is_not_signed_in
    
    get :index

    assert_redirected_to signin_path
  end

  test "user can view discussions after login" do
    user = users(:john)
    sign_in user

    get :index

    assert_select 'title', 'SocialCamp | Discussions'
  end

  # Show discussion-------------------------------------------------
  test "user should login before viewing an discussion" do
    make_sure_user_is_not_signed_in
    discussion = discussions(:one)
    get :show, id: discussion.id

    assert_redirected_to signin_path
  end

  test "user can view an discussion after login" do
    user = users(:john)
    sign_in user

    discussion = discussions(:one)
    get :show, id: discussion.id

    assert_select 'title', 'SocialCamp | View discussion'
  end

  # Edit discussion-------------------------------------------------
  test "user should login before viewing edit discussion page" do
    make_sure_user_is_not_signed_in
    discussion = discussions(:one)
    get :edit, id: discussion.id

    assert_redirected_to signin_path
  end

  test "user cannot view edit page of an discussion created by others" do
    user = users(:jane)
    sign_in user

    discussion = discussions(:one) # discussion created by john
    get :edit, id: discussion.id

    assert_redirected_to discussions_path
  end

  test "user can view edit page of an discussion created by herself" do
    user = users(:john)
    sign_in user

    discussion = discussions(:one) # discussion created by john
    get :edit, id: discussion.id

    assert_select 'title', 'SocialCamp | Edit discussion'
  end

  test "admin can view edit page of an discussion created by others" do
    admin = users(:admin)
    sign_in admin

    discussion = discussions(:one) # discussion created by john
    get :edit, id: discussion.id

    assert_select 'title', 'SocialCamp | Edit discussion'
  end

  # Update discussion-------------------------------------------------
  test "user should login before update a discussion" do
    make_sure_user_is_not_signed_in
    discussion = discussions(:one)
    put :update, id: discussion.id

    assert_redirected_to signin_path
  end

  test "user cannot update a discussion created by others" do
    user = users(:jane)
    sign_in user

    discussion = discussions(:one) # discussion created by john
    put :update, id: discussion.id

    assert_redirected_to discussions_path
  end

  test "user can update a discussion created by herself" do
    user = users(:john)
    sign_in user

    discussion = discussions(:one) # discussion created by john
    updated_subject = "foobar"
    updated_content = "Lorem Ipsum"
    put :update, id: discussion.id, discussion: { subject: updated_subject,
                                                  content: updated_content }

    assert_redirected_to discussion

    updated_discussion = Discussion.find discussion.id

    assert_equal updated_subject, updated_discussion.subject
    assert_equal updated_content, updated_discussion.content
    assert_equal user.id, updated_discussion.user_id
  end

  test "admin can update a discussion created by another user" do
    admin = users(:admin)
    sign_in admin

    discussion = discussions(:two) # discussion created by john
    updated_subject = "foobar"
    updated_content = "Lorem Ipsum"
    put :update, id: discussion.id, discussion: { subject: updated_subject,
                                                  content: updated_content }

    assert_redirected_to discussion

    updated_discussion = Discussion.find discussion.id

    assert_equal updated_subject, updated_discussion.subject
    assert_equal updated_content, updated_discussion.content
    assert_not_equal admin.id, updated_discussion.user_id
  end

  test "upon successful discussion update there should be a changelog" do
    user = users(:john)
    sign_in user

    discussion = discussions(:one) # discussion created by john
    updated_subject = "foobar"
    updated_content = "Lorem Ipsum"
    put :update, id: discussion.id, discussion: { subject: updated_subject,
                                                  content: updated_content }

    assert_redirected_to discussion

    updated_discussion = Discussion.find discussion.id

    changelog = Changelog.last

    assert_equal updated_discussion, changelog.trackable
    assert_equal ActionType::UPDATE, changelog.action_type_id
    assert_equal user.id, changelog.user_id
  end


  # Destroy discussion-------------------------------------------------
  test "user should login before destroy a discussion" do
    make_sure_user_is_not_signed_in
    discussion = discussions(:one)
    delete :destroy, id: discussion.id

    assert_redirected_to signin_path
  end

  test "user cannot destroy a discussion created by others" do
    user = users(:jane)
    sign_in user

    discussion = discussions(:one) # discussion created by john
    delete :destroy, id: discussion.id

    assert_redirected_to discussions_path

    discussion_attempted_to_destroy = Discussion.find discussion.id

    refute discussion_attempted_to_destroy.nil?
  end

  test "user can destroy a discussion created by herself" do
    user = users(:john)
    sign_in user

    discussion = discussions(:one) # discussion created by john
    delete :destroy, id: discussion.id

    assert_redirected_to discussions_path

    discussion_attempted_to_destroy = Discussion.find_by_id discussion.id

    assert discussion_attempted_to_destroy.nil?
  end

  test "admin can destroy a discussion created by another user" do
    admin = users(:admin)
    sign_in admin

    discussion = discussions(:one) # discussion created by john
    delete :destroy, id: discussion.id

    assert_redirected_to discussions_path

    discussion_attempted_to_destroy = Discussion.find_by_id discussion.id

    assert discussion_attempted_to_destroy.nil?
  end

  test "upon successful discussion destroy there should be a changelog" do
    user = users(:john)
    sign_in user

    discussion = discussions(:one) # discussion created by john
    delete :destroy, id: discussion.id

    discussion_attempted_to_destroy = Discussion.find_by_id discussion.id

    changelog = Changelog.last

    assert_equal discussion_attempted_to_destroy, changelog.trackable
    assert_equal ActionType::DESTROY, changelog.action_type_id
    assert_equal user.id, changelog.user_id
  end

end
