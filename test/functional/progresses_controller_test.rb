require 'test_helper'

class ProgressesControllerTest < ActionController::TestCase
  test "user should login before viewing progress page" do
  	make_sure_user_is_not_signed_in

    get :all

    assert_redirected_to signin_path
  end

  test "progress page should have title 'SocialCamp | Progress'" do
  	user = users(:john)
  	sign_in user

    get :all
    assert_select 'title', 'SocialCamp | Progress'
    assert_select 'div#progresses', count: 1
    assert_select 'span#rss', count: 1
    assert_select 'div#changelogs', count: 1
    assert_select 'div#changelogs p[id *= changelog-]', count: assigns(:changelogs).size
  end

end
