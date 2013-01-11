# == Schema Information
#
# Table name: users
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  email      :string(255)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  EMAIL_VALID = "foo@nltechdev.com"
  NAME_VALID = "foobar"
  NAME_TOO_LONG = "a" * 21
  PASSWORD_VALID = "1234Abcd"
  PASSWORD_TOO_SHORT = "a" * 5

  setup do
    @user = Factory(:user)
  end

  test "user should have a name" do
  	user = create(name: nil)

  	assert user.invalid?

  	user.name = NAME_VALID

  	assert user.valid?
  end

  test "user name should be at most 20 characters" do
  	user = create(name: NAME_TOO_LONG)

  	assert user.invalid?

  	user.name = NAME_VALID

  	assert user.valid?
  end

  test "user should have an email" do
  	user = create(email: nil)

  	assert user.invalid?

  	user.email = EMAIL_VALID

  	assert user.valid?
  end

  test "user should have an email ending in nltechdev.com" do
  	# invalid_emails = %w[user@foo,com user_at_foo.org example.user@foo.]
  	# valid_emails = %w[user@foo.com A_USER@f.b.org frst.lst@foo.jp a+b@baz.cn]

  	invalid_emails = %w[user@foo.com A_USER@f.b.org frst.lst@foo.jp a+b@baz.cn]
  	valid_emails = %w[abc@nltechdev.com foo@nltechdev.com dpli@NLTechDev.com]

  	user = create(email: nil)

  	invalid_emails.each do |invalid_email|
  		user.email = invalid_email
  		assert user.invalid?
  	end

  	valid_emails.each do |valid_email|
  		user.email = valid_email
  		assert user.valid?
  	end
  end

  test "user name should be unique" do
    user = create()

    user_with_same_name = user.dup
    user_with_same_name.email = "foo#{user.email}"

    user.save

    assert user_with_same_name.invalid?
  end

  test "user name should be unique, name of same case should be invalid" do
    user = create()

    user_with_same_name = user.dup
    user_with_same_name.email = "foo#{user.email}"

    user.save

    assert user_with_same_name.invalid?
  end

  test "user name should be unique, name of different case should be valid" do
    user = create()

    user_with_same_name = user.dup
    user_with_same_name.email = "foo#{user.email}"
    user_with_same_name.name = user.name.upcase

    user.save

    assert user_with_same_name.valid?
  end

  test "user email should be unique" do
  	user = create()

  	user_with_same_email = user.dup
    user_with_same_email.name = "foo #{user.name}"

  	user.save

  	assert user_with_same_email.invalid?
  end

  test "user email should be unique, email should be case insensitive" do
  	user = create()

  	user_with_same_email = user.dup
    user_with_same_email.name = "foo #{user.name}"
  	user_with_same_email.email.upcase!

  	user.save

  	assert user_with_same_email.invalid?
  end

  test "password should be present" do
  	user = create(password: nil)

  	assert user.invalid?
  end

  test "password should be long enough" do
  	user = create(password: PASSWORD_TOO_SHORT, password_confirmation: PASSWORD_TOO_SHORT)
  	assert user.invalid?
  end

  test "password_confirmation should be present" do
  	user = create(password_confirmation: nil)

  	assert user.invalid?
  end

  test "password and password_confirmation should match" do
  	user = create(password_confirmation: PASSWORD_VALID.reverse)

  	assert user.invalid?
  end

  test "user should authenticate with correct password" do
  	correct_password = PASSWORD_VALID

  	assert_equal @user, @user.authenticate(correct_password)
  end

  test "user should not authenticate with incorrect password" do
  	incorrect_password = @user.password.reverse

  	refute @user.authenticate(incorrect_password)
  end

  test "user should respond to attribute calls" do
  	assert @user.respond_to? :name
  	assert @user.respond_to? :email
  	assert @user.respond_to? :password_digest
  	assert @user.respond_to? :password
  	assert @user.respond_to? :password_confirmation
  	assert @user.respond_to? :authenticate
  end

  private
    def create(options = {})
      User.new({
        name: NAME_VALID,
        email: EMAIL_VALID,
        password: PASSWORD_VALID,
        password_confirmation: PASSWORD_VALID
      }.merge(options))
    end

end
