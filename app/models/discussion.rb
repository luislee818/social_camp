class Discussion < ActiveRecord::Base
  include FinalWordsCollector

  belongs_to :user
  has_many :comments, dependent: :destroy
  has_many :changelogs, as: :trackable

  scope :past, where("updated_at < ?", Date.today.beginning_of_day.utc).order('updated_at desc')
  scope :today, lambda { 
    where("updated_at >= ? and updated_at <= ?", 
           Date.today.beginning_of_day.utc, Date.today.end_of_day.utc)
    .order('updated_at desc')
  }
  
  attr_accessible :content, :subject

  validates :subject, presence: true, length: { maximum: 50 }
  validates :content, presence: true
  validates :user_id, presence: true

  def display_title
    subject
  end

  def last_update_content
    if comments.count == 0
      content
    else
      last_comment.content
    end
  end

  def last_update_user
    if comments.count == 0
      user
    else
      last_comment.user
    end
  end

  def last_update_time
    if comments.count == 0
      updated_at
    else
      last_comment.updated_at
    end
  end
  
  private

    def last_comment
      comments.latest_update_first.first
    end
end
