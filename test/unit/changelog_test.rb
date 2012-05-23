require 'test_helper'

class ChangelogTest < ActiveSupport::TestCase
  ACTION_TYPE_ID_VALID = 1

  DEFAULT_OPTIONS = {
    action_type_id: ACTION_TYPE_ID_VALID
  }
  
  setup do
    @user = users(:john)
    @discussion = discussions(:discussion_with_comments)
  end

  # validations

  test "changelog should have user_id" do
  	trackable = @discussion
  	changelog = build_changelog_for_trackable(trackable)

  	assert changelog.invalid?

  	changelog.user_id = @user.id

  	assert changelog.valid?
  end

  test "changelog should have action_type_id" do
  	trackable = @discussion
  	changelog = build_changelog_for_trackable(trackable, action_type_id: nil)
  	changelog.user_id = @user.id

  	assert changelog.invalid?

  	changelog.action_type_id = ACTION_TYPE_ID_VALID

  	assert changelog.valid?
  end

  test "changelog should have polymorhpic trackable attributes" do
  	trackable = @discussion

  	changelog = Changelog.new do |c|
  		c.user_id = @user.id
  		c.action_type_id = ACTION_TYPE_ID_VALID
  		c.save
  	end

  	assert changelog.invalid?
  end

  private

    def build_changelog_for_trackable(trackable, options = {})
      trackable.changelogs.build(DEFAULT_OPTIONS.merge(options))
    end
end
