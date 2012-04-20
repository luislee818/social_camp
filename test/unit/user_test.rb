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


  test "user should have a name" do
  	user = User.new(email: EMAIL_VALID,
  					password: PASSWORD_VALID,
  					password_confirmation: PASSWORD_VALID)

  	assert user.invalid?

  	user.name = NAME_VALID

  	assert user.valid?
  end

  test "user name should be at most 20 characters" do
  	user = User.new(name: NAME_TOO_LONG, 
  					email: EMAIL_VALID,
  					password: PASSWORD_VALID,
  					password_confirmation: PASSWORD_VALID)

  	assert user.invalid?

  	user.name = NAME_VALID

  	assert user.valid?
  end

  test "user should have an email" do
  	user = User.new(name: NAME_VALID,
  					password: PASSWORD_VALID,
  					password_confirmation: PASSWORD_VALID)

  	assert user.invalid?

  	user.email = EMAIL_VALID

  	assert user.valid?
  end

  test "user should have an email ending in nltechdev.com" do
  	# invalid_emails = %w[user@foo,com user_at_foo.org example.user@foo.]
  	# valid_emails = %w[user@foo.com A_USER@f.b.org frst.lst@foo.jp a+b@baz.cn]

  	invalid_emails = %w[user@foo.com A_USER@f.b.org frst.lst@foo.jp a+b@baz.cn]
  	valid_emails = %w[abc@nltechdev.com foo@nltechdev.com dpli@NLTechDev.com]

  	user = User.new(name: NAME_VALID,
  					password: PASSWORD_VALID,
  					password_confirmation: PASSWORD_VALID)

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
  	user = User.new(name: NAME_VALID, 
  					email: EMAIL_VALID,
  					password: PASSWORD_VALID,
  					password_confirmation: PASSWORD_VALID)

  	user_with_same_email = user.dup

  	user.save

  	assert user_with_same_email.invalid?
  end

  test "user name should be unique, email should be case insensitive" do
  	user = User.new(name: NAME_VALID, 
  					email: EMAIL_VALID,
  					password: PASSWORD_VALID,
  					password_confirmation: PASSWORD_VALID)

  	user_with_same_email = user.dup
  	user_with_same_email.email.upcase!

  	user.save

  	assert user_with_same_email.invalid?
  end

  test "password should be present" do
  	user = User.new(name: NAME_VALID, 
  					email: EMAIL_VALID,
  					password_confirmation: PASSWORD_VALID)

  	assert user.invalid?
  end

  test "password should be long enough" do
  	user = User.new(name: NAME_VALID, 
  					email: EMAIL_VALID,
  					password: PASSWORD_TOO_SHORT,
  					password_confirmation: PASSWORD_TOO_SHORT)

  	assert user.invalid?
  end

  test "password_confirmation should be present" do
  	user = User.new(name: NAME_VALID, 
  					email: EMAIL_VALID,
  					password: PASSWORD_VALID)

  	assert user.invalid?
  end

  test "password and password_confirmation should match" do
  	user = User.new(name: NAME_VALID, 
  					email: EMAIL_VALID,
  					password: PASSWORD_VALID,
  					password_confirmation: PASSWORD_VALID.reverse)

  	assert user.invalid?
  end

  test "user should authenticate with correct password" do
  	user = users(:john)
  	correct_password = PASSWORD_VALID

  	assert_equal user, user.authenticate(correct_password)
  end

  test "user should not authenticate with incorrect password" do
  	user = users(:john)
  	correct_password = PASSWORD_VALID.reverse

  	refute user.authenticate(correct_password)
  end

  test "user should respond to attribute calls" do
  	user = users(:john)

  	assert user.respond_to? :name
  	assert user.respond_to? :email
  	assert user.respond_to? :password_digest
  	assert user.respond_to? :password
  	assert user.respond_to? :password_confirmation
  	assert user.respond_to? :authenticate
  end

end
