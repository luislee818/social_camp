class Comment < ActiveRecord::Base
  belongs_to :discussion
  belongs_to :user

  attr_accessible :content

  scope :latest_update_first, order('updated_at desc')

  validates :content, presence: true
  validates :discussion_id, presence: true
  validates :user_id, presence: true
end
