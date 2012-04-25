require 'test_helper'

class ChangelogTest < ActiveSupport::TestCase
  ACTION_TYPE_ID_VALID = 1

  test "changelog should have user_id" do
  	trackable = discussions(:one)
  	user = users(:john)
  	changelog = trackable.changelogs.build
  	changelog.action_type_id = ACTION_TYPE_ID_VALID

  	assert changelog.invalid?

  	changelog.user_id = user.id

  	assert changelog.valid?
  end

  test "changelog should have action_type_id" do
  	trackable = discussions(:one)
  	user = users(:john)
  	changelog = trackable.changelogs.build
  	changelog.user_id = user.id

  	assert changelog.invalid?

  	changelog.action_type_id = ACTION_TYPE_ID_VALID

  	assert changelog.valid?
  end

  test "changelog should have polymorhpic trackable attributes" do
  	trackable = discussions(:one)
  	user = users(:john)

  	changelog = Changelog.new do |c|
  		c.user_id = user.id
  		c.action_type_id = ACTION_TYPE_ID_VALID
  		c.save
  	end

  	assert changelog.invalid?
  end
end
