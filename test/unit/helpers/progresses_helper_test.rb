require 'test_helper'

class ProgressesHelperTest < ActionView::TestCase

	ACTION_TYPE_INVALID = 100

  setup do
    @trackable = discussions(:discussion_with_comments)
    @trackable_with_long_display_name = discussions(:discussion_with_long_subject)
    @user = users(:john)
    @user_gravatar_id = Digest::MD5::hexdigest(@user.email.downcase)
  end

  # log_change

	test "log_change: ActionType should be valid" do
		assert_raise RuntimeError do
      log_change(@trackable, ACTION_TYPE_INVALID, @user.id)
		end
	end

  test "log_change: should log ADD action" do
    changelog = log_change(@trackable, ActionType::ADD, @user.id)

    assert_equal @user.id, changelog.user_id
    assert_equal ActionType::ADD, changelog.action_type_id
    assert changelog.destroyed_content_summary.blank?
  end

  test "log_change: should log UPDATE action" do
    changelog = log_change(@trackable, ActionType::UPDATE, @user.id)

    assert_equal @user.id, changelog.user_id
    assert_equal ActionType::UPDATE, changelog.action_type_id
    assert changelog.destroyed_content_summary.blank?
  end

  test "log_change: should log DESTROY action" do
    changelog = log_change(@trackable, ActionType::DESTROY, @user.id)

    assert_equal @user.id, changelog.user_id
    assert_equal ActionType::DESTROY, changelog.action_type_id
    assert_equal @trackable.final_words, changelog.destroyed_content_summary
  end

  # display_mini_log

  test "display_mini_log: Display nothing when user associated with changelog doesn't exist" do
    changelog = log_change(@trackable, ActionType::ADD, -1)

    assert_nil display_mini_log(changelog)
  end

  test "display_mini_log: Display a mini log for ADD action" do
    changelog = log_change(@trackable, ActionType::ADD, @user.id)

    assert_match /Added\s(\w+\s)+ago\sby\s#{@user.name}/o, display_mini_log(changelog)
  end

  test "display_mini_log: Display a mini log for UPDATE action" do
    changelog = log_change(@trackable, ActionType::UPDATE, @user.id)

    assert_match /Updated\s(\w+\s)+ago\sby\s#{@user.name}/o, display_mini_log(changelog)
  end

  test "display_mini_log: Display a mini log for DESTROY action" do
    changelog = log_change(@trackable, ActionType::DESTROY, @user.id)

    assert_match /Deleted\s(\w+\s)+ago\sby\s#{@user.name}/o, display_mini_log(changelog)
  end

  # display_full_log

  test "display_full_log: Display nothing when user associated with changelog doesn't exist" do
    changelog = log_change(@trackable, ActionType::ADD, -1)

    assert_nil display_full_log(changelog)
  end

  # display_full_log - show user and relative timestamp (add, update, delete)
  test "display_full_log: Display a full log for ADD action, with user name and relative timestamp" do
    changelog = log_change(@trackable, ActionType::ADD, @user.id)

    assert_match /<img[^>]+\/>\s+<a[^>]+>#{@user.name}<\/a>\s+added\s+discussion\s+<a[^>]+>#{@trackable.display_title}<\/a>\s+<span[^>]+>[\w\s]+&nbsp;ago<\/span>/o, 
                  display_full_log(changelog)
  end

  test "display_full_log: Display a full log for ADD action, with user name and relative timestamp, truncate when display_title is too long" do
    changelog = log_change(@trackable_with_long_display_name, ActionType::ADD, @user.id)

    assert_match /<img[^>]+\/>\s+<a[^>]+>#{@user.name}<\/a>\s+added\s+discussion\s+<a[^>]+>#{truncate(@trackable_with_long_display_name.display_title, length: ProgressesHelper::DISPLAY_TITLE_MAX_LENGTH)}<\/a>\s+<span[^>]+>[\w\s]+&nbsp;ago<\/span>/o, 
                  display_full_log(changelog)
  end

  test "display_full_log: Display a full log for UPDATE action, with user name and relative timestamp" do
    changelog = log_change(@trackable, ActionType::UPDATE, @user.id)

    assert_match /<img[^>]+\/>\s+<a[^>]+>#{@user.name}<\/a>\s+updated\s+discussion\s+<a[^>]+>#{@trackable.display_title}<\/a>\s+<span[^>]+>[\w\s]+&nbsp;ago<\/span>/o, 
                  display_full_log(changelog)
  end

  test "display_full_log: Display a full log for DESTROY action, with user name and relative timestamp" do
    @trackable.destroy
    changelog = log_change(@trackable, ActionType::DESTROY, @user.id)

    assert_match /<img[^>]+\/>\s+<a[^>]+>#{@user.name}<\/a>\s+deleted\s+discussion\s+#{@trackable.display_title}\s+<span[^>]+>[\w\s]+&nbsp;ago<\/span>/o, 
                  display_full_log(changelog)
  end

  # display_full_log - show user and absolute timestamp (add, update, delete)
  test "display_full_log: Display a full log for ADD action, with user name and absolute timestamp" do
    changelog = log_change(@trackable, ActionType::ADD, @user.id)

    assert_match /<img[^>]+\/>\s+<a[^>]+>#{@user.name}<\/a>\s+added\s+discussion\s+<a[^>]+>#{@trackable.display_title}<\/a>\s+<span[^>]+>on&nbsp;[^<]+<\/span>/o, 
                  display_full_log(changelog, show_relative_timestamp: false)
  end

  test "display_full_log: Display a full log for ADD action, with user name and absolute timestamp, truncate when display_title is too long" do
    changelog = log_change(@trackable_with_long_display_name, ActionType::ADD, @user.id)

    assert_match /<img[^>]+\/>\s+<a[^>]+>#{@user.name}<\/a>\s+added\s+discussion\s+<a[^>]+>#{truncate(@trackable_with_long_display_name.display_title, length: ProgressesHelper::DISPLAY_TITLE_MAX_LENGTH)}<\/a>\s+<span[^>]+>on&nbsp;[^<]+<\/span>/o, 
                  display_full_log(changelog, show_relative_timestamp: false)
  end

  test "display_full_log: Display a full log for UPDATE action, with user name and absolute timestamp" do
    changelog = log_change(@trackable, ActionType::UPDATE, @user.id)

    assert_match /<img[^>]+\/>\s+<a[^>]+>#{@user.name}<\/a>\s+updated\s+discussion\s+<a[^>]+>#{@trackable.display_title}<\/a>\s+<span[^>]+>on&nbsp;[^<]+<\/span>/o, 
                  display_full_log(changelog, show_relative_timestamp: false)
  end

  test "display_full_log: Display a full log for DESTROY action, with user name and absolute timestamp" do
  	@trackable.destroy
    changelog = log_change(@trackable, ActionType::DESTROY, @user.id)

    assert_match /<img[^>]+\/>\s+<a[^>]+>#{@user.name}<\/a>\s+deleted\s+discussion\s+#{@trackable.display_title}\s+<span[^>]+>on&nbsp;[^<]+<\/span>/o, 
                  display_full_log(changelog, show_relative_timestamp: false)
  end

  # display_full_log - doesn't show user but show relative timestamp (add, update, delete)
  test "display_full_log: Display a full log for ADD action, with relative timestamp but no user name" do
    changelog = log_change(@trackable, ActionType::ADD, @user.id)

    assert_match /Added\s+discussion\s+<a[^>]+>#{@trackable.display_title}<\/a>\s+<span[^>]+>[\w\s]+&nbsp;ago<\/span>/o, 
                  display_full_log(changelog, show_user: false)
  end

  test "display_full_log: Display a full log for ADD action, with relative timestamp but no user name, truncate when display_title is too long" do
    changelog = log_change(@trackable_with_long_display_name, ActionType::ADD, @user.id)

    assert_match /Added\s+discussion\s+<a[^>]+>#{truncate(@trackable_with_long_display_name.display_title, length: ProgressesHelper::DISPLAY_TITLE_MAX_LENGTH)}<\/a>\s+<span[^>]+>[\w\s]+&nbsp;ago<\/span>/o, 
                  display_full_log(changelog, show_user: false)
  end

  test "display_full_log: Display a full log for UPDATE action, with relative timestamp but no user name" do
    changelog = log_change(@trackable, ActionType::UPDATE, @user.id)

    assert_match /Updated\s+discussion\s+<a[^>]+>#{@trackable.display_title}<\/a>\s+<span[^>]+>[\w\s]+&nbsp;ago<\/span>/o, 
                  display_full_log(changelog, show_user: false)
  end

  test "display_full_log: Display a full log for DESTROY action, with relative timestamp but no user name" do
  	@trackable.destroy
    changelog = log_change(@trackable, ActionType::DESTROY, @user.id)

    assert_match /Deleted\s+discussion\s+#{@trackable.display_title}\s+<span[^>]+>[\w\s]+&nbsp;ago<\/span>/o, 
                  display_full_log(changelog, show_user: false)
  end

  # display_text_log

  test "display_text_log: Display a text log for ADD action" do
    changelog = log_change(@trackable, ActionType::ADD, @user.id)

    assert_match /Added\s+discussion\s+<a[^>]+>#{@trackable.display_title}<\/a>\s+<span[^>]+>[\w\s]+&nbsp;ago<\/span>/o, 
                  display_full_log(changelog, show_user: false)
  end

end
