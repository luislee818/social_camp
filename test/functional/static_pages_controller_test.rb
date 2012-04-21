require 'test_helper'

class StaticPagesControllerTest < ActionController::TestCase
  test "should get home" do
    get :home
    assert_response :success
  end
  
  test "home page title should be 'SocialCamp'" do
    get :home
    assert_select 'title', 'SocialCamp'
  end

  test "should get help" do
    get :help
    assert_response :success
  end
  
  test "help page title should be 'SocialCamp | Help'" do
    get :help
    assert_select 'title', 'SocialCamp | Help'
  end

  test "should get about" do
    get :about
    assert_response :success
  end
  
  test "about page title should be 'SocialCamp | About Us'" do
    get :about
    assert_select 'title', 'SocialCamp | About Us'
  end

  test "should get contact" do
    get :contact
    assert_response :success
  end
  
  test "home page title should be 'SocialCamp | Contact'" do
    get :contact
    assert_select 'title', 'SocialCamp | Contact'
  end

end
