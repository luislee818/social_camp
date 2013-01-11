require 'test_helper'

class ProgressesControllerTest < ActionController::TestCase
  setup do
    # user
    @john = Factory(:john)

    # trackables and changelogs
    discussion = Factory(:discussion, user: @john)
    Factory(:changelog_add, trackable: discussion, user: @john)

    comment = Factory(:comment, discussion: discussion, user: @john)
    Factory(:changelog_add, trackable: comment, user: @john)
    Factory(:changelog_destroy, trackable: comment, user: @john)

    event = Factory(:event, user: @john)
    Factory(:changelog_add, trackable: event, user: @john)
    Factory(:changelog_update, trackable: event, user: @john)
  end

  test "user should login before viewing progress page" do
  	make_sure_user_is_not_signed_in

    get :all

    assert_redirected_to signin_path
  end

  test "progress page should have title 'SocialCamp | Progress'" do
  	sign_in @john

    get :all
    assert_select 'title', 'SocialCamp | Progress'
    assert_select 'div#progresses', count: 1
    assert_select 'span#rss', count: 1
    assert_select 'div#changelogs', count: 1
    assert_select 'div#changelogs p[id *= changelog-]', count: assigns(:changelogs).size
  end

end
