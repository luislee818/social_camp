require 'test_helper'

class DashboardControllerTest < ActionController::TestCase
  test "user should signin before viewing dashboard page" do
    make_sure_user_is_not_signed_in
    
    get :home
    
    assert_redirected_to signin_path
  end

  test "dashboard page title should be 'SocialCamp | Dashboard'" do
    user = users(:john)
    sign_in user
    get :home
    assert_select 'title', 'SocialCamp | Dashboard'
  end

  # TODO: test redirect of login user?
 #  test "signed in user visiting root should route to dashboard" do
 #  	user = users(:john)
 #    sign_in user

	# assert_routing '/', { controller: "dashboard", action: "home" }
 #  end

end
