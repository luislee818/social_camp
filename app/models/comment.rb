class Comment < ActiveRecord::Base
  include FinalWordsCollector

  belongs_to :discussion
  belongs_to :user
  has_many :changelogs, as: :trackable

  attr_accessible :content

  scope :latest_update_first, order('updated_at desc')

  validates :content, presence: true
  validates :discussion_id, presence: true
  validates :user_id, presence: true

  def display_title
    content
  end

end
