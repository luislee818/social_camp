class Comment < ActiveRecord::Base
  belongs_to :discussion
  belongs_to :user

  attr_accessible :content

  validates :content, presence: true
  validates :discussion_id, presence: true
  validates :user_id, presence: true
end
