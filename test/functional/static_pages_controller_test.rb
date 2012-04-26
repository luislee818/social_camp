require 'test_helper'

class StaticPagesControllerTest < ActionController::TestCase
  test "anonymous user should get home" do
    make_sure_user_is_not_signed_in
    get :home
    assert_response :success
  end
  
  test "home page title should be 'SocialCamp'" do
    make_sure_user_is_not_signed_in
    get :home
    assert_select 'title', 'SocialCamp'
  end

  test "should get help" do
    make_sure_user_is_not_signed_in
    get :help
    assert_response :success
  end
  
  test "help page title should be 'SocialCamp | Help'" do
    make_sure_user_is_not_signed_in
    get :help
    assert_select 'title', 'SocialCamp | Help'
  end

  test "should get about" do
    make_sure_user_is_not_signed_in
    get :about
    assert_response :success
  end
  
  test "about page title should be 'SocialCamp | About Us'" do
    make_sure_user_is_not_signed_in
    get :about
    assert_select 'title', 'SocialCamp | About Us'
  end

  test "should get contact" do
    make_sure_user_is_not_signed_in
    get :contact
    assert_response :success
  end
  
  test "home page title should be 'SocialCamp | Contact'" do
    make_sure_user_is_not_signed_in
    get :contact
    assert_select 'title', 'SocialCamp | Contact'
  end

end
