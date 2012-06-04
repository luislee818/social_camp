# require 'simplecov'
# SimpleCov.start

ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  # fixtures :all

  # Add more helper methods to be used by all tests here...
  def sign_in(user)
    cookies[:user_id] = user.id
  end
  
  def sign_out
    cookies[:user_id] = nil
  end
  
  alias :make_sure_user_is_not_signed_in :sign_out
end
