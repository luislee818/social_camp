require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  setup do
    # users
    @john = Factory(:john)
    @jane = Factory(:jane)
    @admin = Factory(:admin)

    # discussion
    @discussion = Factory(:discussion, user: @john)

    # comment
    Factory(:comment, discussion: @discussion, user: @john)

    # event
    Factory(:event, user: @john)

    # changelog
    Factory(:changelog_add, trackable: @discussion, user: @john)
  end

  # Index ----------------------------------------------

  test "user should sign in before visiting index page" do
    make_sure_user_is_not_signed_in
    get :index

    assert_redirected_to signin_path
  end

  test "user should be able to view index page after sign in" do
    sign_in @john
    get :index

    assert_response :success

    assert assigns(:users)

    assert_template 'index'
    assert_select 'title', 'SocialCamp | People'
    assert_select 'div#users', count: 1
  end

  # Sign up----------------------------------------------

  test "should get new" do
    get :new
    assert_response :success

    assert_template 'new'
    assert_select 'div#user-new', count: 1
    assert_select 'title', 'SocialCamp | Sign up'
  end

  test "user should sign up with valid information" do
    post :create, user: { name: "foo", email: "bar@nltechdev.com",
                          password: "secret", password_confirmation: "secret" }
    user = User.find_by_name "foo"
    refute user.nil?

    assert_redirected_to user

    assert_equal user.id, cookies[:user_id]
  end

  test "user should not sign up with invalid information" do
    post :create, user: { name: "", email: "bar@nltechdev.com",
                          password: "secret", password_confirmation: "secret" }
    user = User.find_by_name "foo"
    assert user.nil?
    assert_template 'new'
  end

  # Sign in----------------------------------------------

  test "user should sign in before visting update profile page" do
    make_sure_user_is_not_signed_in

    get :edit, id: @john.id
    assert_redirected_to signin_path
  end

  # Show user----------------------------------------------

  test "user should sign in before visiting show profile page" do
    make_sure_user_is_not_signed_in
    get :show, id: @john.id
    assert_redirected_to signin_path
  end

  test "user should be able to view her own profile page after signing in" do
    sign_in @john

    get :show, id: @john.id

    assert_response :success
    assert_template 'show'
    assert_select 'div#user-show', count:1
    assert_select 'div#user-show div#avatar', count: 1
    assert_select 'div#user-show div#user-info', count: 1
  end

  test "user should be able to view another user's profile page after signing in" do
    sign_in @john

    get :show, id: @jane.id

    assert_response :success
    assert_template 'show'
    assert_select 'div#user-show', count:1
    assert_select 'div#user-show div#avatar', count: 1
    assert_select 'div#user-show div#user-info', count: 1
  end

  # Edit profile----------------------------------------------

  test "user should sign in before visiting edit profile page" do
    make_sure_user_is_not_signed_in
    get :edit, id: @john.id
    assert_redirected_to signin_path
  end

  test "user should be able to view edit profile page after signing in" do
    sign_in @john
    get :edit, id: @john.id
    assert_response :success
    assert_template 'edit'
    assert_select 'title', 'SocialCamp | Edit profile'
    assert_select 'div#user-edit', count: 1
  end

  test "non-admin user should not be to view edit profile page of another user" do
    sign_in @john
    get :edit, id: @jane.id

    assert_redirected_to root_path
  end

  test "admin user should be to view edit profile page of another user" do
    sign_in @admin
    get :edit, id: @jane.id

    assert_template 'edit'
    assert_select 'div#user-edit', count: 1
  end

  # Update profile----------------------------------------------

  test "user should sign in before updating profile" do
    make_sure_user_is_not_signed_in
    put :update, id: @john.id
    assert_redirected_to signin_path
  end

  test "user should not update profile with invalid information" do
    sign_in @john
    put :update, id: @john.id, user: { name: "", email: "bar@nltechdev.com",
                                      password: "secret", password_confirmation: "secret" }
    assert_template 'edit'

    john = User.find @john.id
    assert_equal @john.name, john.name
    assert_equal @john.email, john.email
  end

  test "user should update profile with valid information" do
    sign_in @john
    put :update, id: @john.id, user: { name: "johnny", email: "bar@nltechdev.com",
                                      password: "new_secret", password_confirmation: "new_secret" }
    assert_redirected_to @john

    john = User.find @john.id
    assert_equal "johnny", john.name
    assert_equal "bar@nltechdev.com", john.email
  end

  test "non-admin user should not be able to update another user" do
    sign_in @john
    put :update, id: @jane.id

    assert_redirected_to root_path
  end

  test "admin user should update profile of another user" do
    sign_in @admin
    put :update, id: @john.id, user: { name: "johnny", email: "bar@nltechdev.com",
                                      password: "new_secret", password_confirmation: "new_secret" }
    assert_redirected_to @john

    john = User.find @john.id
    assert_equal "johnny", john.name
    assert_equal "bar@nltechdev.com", john.email
  end

  # Delete user----------------------------------------------

  test "user should sign in before delete profile" do
    make_sure_user_is_not_signed_in
    delete :destroy, id: @john.id
    assert_redirected_to signin_path
  end

  test "user should be admin to delete other user" do
    sign_in @john
    delete :destroy, id: @jane.id

    assert_redirected_to root_path
  end

  test "admin should be able to delete other user's account" do
    sign_in @admin

    delete :destroy, id: @jane.id

    assert_redirected_to users_path

    jane_after_delete = User.find_by_name @jane.name
    assert jane_after_delete.nil?
  end

  test "admin should not be able to delete her own account" do
    sign_in @admin

    delete :destroy, id: @admin.id

    assert_redirected_to users_path

    admin_after_delete_attempt = User.find_by_name @admin.name
    refute admin_after_delete_attempt.nil?
  end

  # collateral effects after deletion

  test "upon successful account destroy events of that user should be destroyed" do
    sign_in @admin

    user_to_delete = @john

    events = user_to_delete.events.dup

    delete :destroy, id: user_to_delete.id

    assert events.count > 0

    events.each do |obj|
      obj_in_search = Event.find_by_id obj.id

      assert obj_in_search.nil?
    end
  end

  test "upon successful account destroy discussions of that user should be destroyed" do
    sign_in @admin

    user_to_delete = @john

    discussions = user_to_delete.discussions.dup

    delete :destroy, id: user_to_delete.id

    assert discussions.count > 0

    discussions.each do |obj|
      obj_in_search = Event.find_by_id obj.id

      assert obj_in_search.nil?
    end
  end

  test "upon successful account destroy comments of that user should be destroyed" do
    sign_in @admin

    user_to_delete = @john

    comments = user_to_delete.comments.dup

    delete :destroy, id: user_to_delete.id

    assert comments.count > 0

    comments.each do |obj|
      obj_in_search = Event.find_by_id obj.id

      assert obj_in_search.nil?
    end
  end

  test "upon successful account destroy changelogs of that user should be destroyed" do
    sign_in @admin

    user_to_delete = @john

    changelogs = user_to_delete.changelogs.dup

    delete :destroy, id: user_to_delete.id

    assert changelogs.count > 0

    changelogs.each do |obj|
      obj_in_search = Event.find_by_id obj.id

      assert obj_in_search.nil?
    end
  end

end
