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

class User < ActiveRecord::Base
  has_many :events
  
  attr_accessible :email, :name, :password, :password_confirmation

  VALID_EMAIL_REGEX = /\A[\w-]+@nltechdev.com\z/i

  validates :name, presence: true, length: { maximum: 20 }
  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX },
  			uniqueness: { case_sensitive: false }
  validates :password, length: { minimum: 6 }
  validates :password_confirmation, presence: true

  has_secure_password

  before_save { |user| user.email.downcase! }
end
