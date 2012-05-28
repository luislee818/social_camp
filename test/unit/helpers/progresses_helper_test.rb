require 'test_helper'

class ProgressesHelperTest < ActionView::TestCase

	ACTION_TYPE_INVALID = 100

  setup do
    # user
    @john = Factory(:john)
    
    # discussions
    @discussion = Factory(:discussion, user: @john)
    @comment = Factory(:comment, discussion: @discussion, user: @john)
    Factory(:comment, discussion: @discussion, user: @john)
    
    # TODO: change this to be a long comment
    @discussion_with_long_display_name = Factory(:discussion, subject: 'a' * 50, user: @john)
    
    # event
    @event = Factory(:event, user: @john)

  end

  # log_change

	test "log_change: ActionType should be valid" do
		assert_raise RuntimeError do
      log_change(@discussion, ACTION_TYPE_INVALID, @john.id)
		end
	end

  test "log_change: should log ADD action" do
    changelog = log_change(@discussion, ActionType::ADD, @john.id)

    assert_equal @john.id, changelog.user_id
    assert_equal ActionType::ADD, changelog.action_type_id
    assert changelog.destroyed_content_summary.blank?
  end

  test "log_change: should log UPDATE action" do
    changelog = log_change(@discussion, ActionType::UPDATE, @john.id)

    assert_equal @john.id, changelog.user_id
    assert_equal ActionType::UPDATE, changelog.action_type_id
    assert changelog.destroyed_content_summary.blank?
  end

  test "log_change: should log DESTROY action" do
    changelog = log_change(@discussion, ActionType::DESTROY, @john.id)

    assert_equal @john.id, changelog.user_id
    assert_equal ActionType::DESTROY, changelog.action_type_id
    assert_equal @discussion.final_words, changelog.destroyed_content_summary
  end

  # display_mini_log

  test "display_mini_log: Display nothing when user associated with changelog doesn't exist" do
    changelog = log_change(@discussion, ActionType::ADD, -1)

    assert_nil display_mini_log(changelog)
  end

  test "display_mini_log: Display a mini log for ADD action" do
    changelog = log_change(@discussion, ActionType::ADD, @john.id)

    assert_match /Added\s(\w+\s)+ago\sby\s#{@john.name}/o, display_mini_log(changelog)
  end

  test "display_mini_log: Display a mini log for UPDATE action" do
    changelog = log_change(@discussion, ActionType::UPDATE, @john.id)

    assert_match /Updated\s(\w+\s)+ago\sby\s#{@john.name}/o, display_mini_log(changelog)
  end

  test "display_mini_log: Display a mini log for DESTROY action" do
    changelog = log_change(@discussion, ActionType::DESTROY, @john.id)

    assert_match /Deleted\s(\w+\s)+ago\sby\s#{@john.name}/o, display_mini_log(changelog)
  end

  # display_full_log

  test "display_full_log: Display nothing when user associated with changelog doesn't exist" do
    changelog = log_change(@discussion, ActionType::ADD, -1)

    assert_nil display_full_log(changelog)
  end

  # display_full_log - show user and relative timestamp (add, update, delete)
  test "display_full_log: Display a full log for ADD action, with user name and relative timestamp" do
    changelog = log_change(@discussion, ActionType::ADD, @john.id)

    assert_match /<img[^>]+\/>\s+<a[^>]+>#{@john.name}<\/a>\s+added\s+discussion\s+<a[^>]+>#{@discussion.display_title}<\/a>\s+<span[^>]+>[\w\s]+&nbsp;ago<\/span>/o, 
                  display_full_log(changelog)
  end

  test "display_full_log: Display a full log for ADD action, with user name and relative timestamp, truncate when display_title is too long" do
    changelog = log_change(@discussion_with_long_display_name, ActionType::ADD, @john.id)

    assert_match /<img[^>]+\/>\s+<a[^>]+>#{@john.name}<\/a>\s+added\s+discussion\s+<a[^>]+>#{truncate(@discussion_with_long_display_name.display_title, length: ProgressesHelper::DISPLAY_TITLE_MAX_LENGTH)}<\/a>\s+<span[^>]+>[\w\s]+&nbsp;ago<\/span>/o, 
                  display_full_log(changelog)
  end

  test "display_full_log: Display a full log for UPDATE action, with user name and relative timestamp" do
    changelog = log_change(@discussion, ActionType::UPDATE, @john.id)

    assert_match /<img[^>]+\/>\s+<a[^>]+>#{@john.name}<\/a>\s+updated\s+discussion\s+<a[^>]+>#{@discussion.display_title}<\/a>\s+<span[^>]+>[\w\s]+&nbsp;ago<\/span>/o, 
                  display_full_log(changelog)
  end

  test "display_full_log: Display a full log for DESTROY action, with user name and relative timestamp" do
    @discussion.destroy
    changelog = log_change(@discussion, ActionType::DESTROY, @john.id)

    assert_match /<img[^>]+\/>\s+<a[^>]+>#{@john.name}<\/a>\s+deleted\s+discussion\s+#{@discussion.display_title}\s+<span[^>]+>[\w\s]+&nbsp;ago<\/span>/o, 
                  display_full_log(changelog)
  end

  # display_full_log - show user and absolute timestamp (add, update, delete)
  test "display_full_log: Display a full log for ADD action, with user name and absolute timestamp" do
    changelog = log_change(@discussion, ActionType::ADD, @john.id)

    assert_match /<img[^>]+\/>\s+<a[^>]+>#{@john.name}<\/a>\s+added\s+discussion\s+<a[^>]+>#{@discussion.display_title}<\/a>\s+<span[^>]+>on&nbsp;[^<]+<\/span>/o, 
                  display_full_log(changelog, show_relative_timestamp: false)
  end

  test "display_full_log: Display a full log for ADD action, with user name and absolute timestamp, truncate when display_title is too long" do
    changelog = log_change(@discussion_with_long_display_name, ActionType::ADD, @john.id)

    assert_match /<img[^>]+\/>\s+<a[^>]+>#{@john.name}<\/a>\s+added\s+discussion\s+<a[^>]+>#{truncate(@discussion_with_long_display_name.display_title, length: ProgressesHelper::DISPLAY_TITLE_MAX_LENGTH)}<\/a>\s+<span[^>]+>on&nbsp;[^<]+<\/span>/o, 
                  display_full_log(changelog, show_relative_timestamp: false)
  end

  test "display_full_log: Display a full log for UPDATE action, with user name and absolute timestamp" do
    changelog = log_change(@discussion, ActionType::UPDATE, @john.id)

    assert_match /<img[^>]+\/>\s+<a[^>]+>#{@john.name}<\/a>\s+updated\s+discussion\s+<a[^>]+>#{@discussion.display_title}<\/a>\s+<span[^>]+>on&nbsp;[^<]+<\/span>/o, 
                  display_full_log(changelog, show_relative_timestamp: false)
  end

  test "display_full_log: Display a full log for DESTROY action, with user name and absolute timestamp" do
  	@discussion.destroy
    changelog = log_change(@discussion, ActionType::DESTROY, @john.id)

    assert_match /<img[^>]+\/>\s+<a[^>]+>#{@john.name}<\/a>\s+deleted\s+discussion\s+#{@discussion.display_title}\s+<span[^>]+>on&nbsp;[^<]+<\/span>/o, 
                  display_full_log(changelog, show_relative_timestamp: false)
  end

  # display_full_log - doesn't show user but show relative timestamp (add, update, delete)
  test "display_full_log: Display a full log for ADD action, with relative timestamp but no user name" do
    changelog = log_change(@discussion, ActionType::ADD, @john.id)

    assert_match /Added\s+discussion\s+<a[^>]+>#{@discussion.display_title}<\/a>\s+<span[^>]+>[\w\s]+&nbsp;ago<\/span>/o, 
                  display_full_log(changelog, show_user: false)
  end

  test "display_full_log: Display a full log for ADD action, with relative timestamp but no user name, truncate when display_title is too long" do
    changelog = log_change(@discussion_with_long_display_name, ActionType::ADD, @john.id)

    assert_match /Added\s+discussion\s+<a[^>]+>#{truncate(@discussion_with_long_display_name.display_title, length: ProgressesHelper::DISPLAY_TITLE_MAX_LENGTH)}<\/a>\s+<span[^>]+>[\w\s]+&nbsp;ago<\/span>/o, 
                  display_full_log(changelog, show_user: false)
  end

  test "display_full_log: Display a full log for UPDATE action, with relative timestamp but no user name" do
    changelog = log_change(@discussion, ActionType::UPDATE, @john.id)

    assert_match /Updated\s+discussion\s+<a[^>]+>#{@discussion.display_title}<\/a>\s+<span[^>]+>[\w\s]+&nbsp;ago<\/span>/o, 
                  display_full_log(changelog, show_user: false)
  end

  test "display_full_log: Display a full log for DESTROY action, with relative timestamp but no user name" do
  	@discussion.destroy
    changelog = log_change(@discussion, ActionType::DESTROY, @john.id)

    assert_match /Deleted\s+discussion\s+#{@discussion.display_title}\s+<span[^>]+>[\w\s]+&nbsp;ago<\/span>/o, 
                  display_full_log(changelog, show_user: false)
  end

  # display_text_log

  test "display_text_log: Display nothing when user associated with changelog doesn't exist" do
    changelog = log_change(@discussion, ActionType::ADD, -1)

    assert_nil display_text_log(changelog)
  end

  test "display_text_log: Display a text log for ADD action" do
    changelog = log_change(@discussion, ActionType::ADD, @john.id)

    assert_match /#{@john.name}\s+added\s+discussion\s+#{@discussion.display_title}/o, 
                  display_text_log(changelog)
  end

  test "display_text_log: Display a text log for ADD action, truncate when display_title is too long" do
    changelog = log_change(@discussion_with_long_display_name, ActionType::ADD, @john.id)

    assert_match /#{@john.name}\s+added\s+discussion\s+#{truncate(@discussion_with_long_display_name.display_title, length: ProgressesHelper::DISPLAY_TITLE_MAX_LENGTH)}/o, 
                  display_text_log(changelog)
  end

  test "display_text_log: Display a text log for UPDATE action" do
    changelog = log_change(@discussion, ActionType::UPDATE, @john.id)

    assert_match /#{@john.name}\s+updated\s+discussion\s+#{@discussion.display_title}/o, 
                  display_text_log(changelog)
  end

  test "display_text_log: Display a text log for DESTROY action" do
    @discussion.destroy
    changelog = log_change(@discussion, ActionType::DESTROY, @john.id)

    assert_match /#{@john.name}\s+deleted\s+discussion\s+#{@discussion.display_title}/o, 
                  display_text_log(changelog)
  end

  # get_trackable_url

  test "get_trackable_url: Return nil when trackable associated with changelog doesn't exist" do
    changelog = log_change(@discussion, ActionType::ADD, @john.id)
    @discussion.destroy

    assert_nil get_trackable_url(changelog)
  end

  test "get_trackable_url: Return discussion url when trackable is discussion" do
    changelog = log_change(@discussion, ActionType::ADD, @john.id)

    assert_equal discussion_url(@discussion.id), get_trackable_url(changelog)
  end

  test "get_trackable_url: Return comment url when trackable is comment" do
    changelog = log_change(@comment, ActionType::ADD, @john.id)

    assert_equal comment_url(@comment.id), get_trackable_url(changelog)
  end

  test "get_trackable_url: Return event url when trackable is event" do
    changelog = log_change(@event, ActionType::ADD, @john.id)

    assert_equal event_url(@event.id), get_trackable_url(changelog)
  end

  # One line not covered, not sure how to
  # test "get_trackable_url: Return empty string when trackable_type is invalid" do
  #   changelog = Changelog.new(user_id: @john.id,
  #                             action_type_id: ActionType::ADD,
  #                             trackable_id: @discussion.id,
  #                             trackable_type: 'foo')

  #   assert_equal '', get_trackable_url(changelog)
  # end

end
