require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  setup do
    @user = users(:john)
  end
  
  test "should get new" do
    get :new
    assert_response :success
  end
  
  test "show page should display user name in h1" do
    get :show, id: @user
    assert_response :success
    assert_select 'h1', @user.name
  end
  
  # Sign up----------------------------------------------
  
  test "user should sign up with valid information" do
    post :create, user: { name: "foo", email: "bar@nltechdev.com", 
                          password: "secret", password_confirmation: "secret" }
    user = User.find_by_name "foo"
    refute user.nil?
    assert_redirected_to user
    assert_equal user.id, cookies[:user_id]
  end
  
  # TODO: Add all failure cases? Duplicating tests in unit tests?
  test "user should not sign up with invalid information" do
    post :create, user: { name: "", email: "bar@nltechdev.com", 
                          password: "secret", password_confirmation: "secret" }
    user = User.find_by_name "foo"
    assert user.nil?
    assert_template 'new'
  end
  
  # Sign in----------------------------------------------
  
  test "user should sign in before visting update profile page" do
    user = users(:john)
    make_sure_user_is_not_signed_in
    
    get :edit, id: user.id
    assert_redirected_to signin_path
  end
  
  # Edit profile----------------------------------------------
  
  test "Edit profile page title should be 'SocialCamp | Edit profile'" do
    user = users(:john)
    sign_in user
    get :edit, id: user.id
    assert_select 'title', 'SocialCamp | Edit profile'
  end
  
  # TODO: Test elements on page to verify results?
  test "user should not update profile with invalid information" do
    user = users(:john)
    sign_in user
    put :update, id: user.id, user: { name: "", email: "bar@nltechdev.com", 
                                      password: "secret", password_confirmation: "secret" }
    assert_template 'edit'
  end
  
  test "user should update profile with valid information" do
    user = users(:john)
    sign_in user
    put :update, id: user.id, user: { name: "john", email: "bar@nltechdev.com", 
                                      password: "secret", password_confirmation: "secret" }
    assert_redirected_to user
  end
  
  test "user should not be able to visit edit page of another user" do
    user_logged_in = users(:john)
    sign_in user_logged_in
    
    user_to_edit = users(:jane)
    
    get :edit, id: user_to_edit.id
    assert_redirected_to root_path
  end
  
  # TODO: add as integration test?
  test "user should be redirected to the attempted page after sign in" do
    
  end
  
  # Users page----------------------------------------------
  test "user should login before visiting users page" do
    make_sure_user_is_not_signed_in
    get :index
    assert_redirected_to signin_path
  end
  
  test "users page should have title 'SocialCamp | People'" do
    user = users(:john)
    sign_in user
    get :index
    assert_select 'title', 'SocialCamp | People'
  end
  
  # Delete user----------------------------------------------
  test "user should be admin to delete other user" do
    john = users(:john)
    sign_in john
    
    jane = users(:jane)
    
    delete :destroy, id: jane.id 
    
    assert_redirected_to root_path
  end
  
  test "admin should be able to delete other user's account" do
    admin = users(:admin)
    sign_in admin
    
    jane = users(:jane)
    
    delete :destroy, id: jane.id
    
    assert_redirected_to users_path
    
    jane_after_delete = User.find_by_name jane.name
    assert jane_after_delete.nil?
  end
  
  test "admin should not be able to delete her own account" do
    admin = users(:admin)
    sign_in admin

    delete :destroy, id: admin.id
    
    assert_redirected_to users_path
    
    admin_after_delete_attempt = User.find_by_name admin.name
    refute admin_after_delete_attempt.nil?
  end

end
