class Discussion < ActiveRecord::Base
  belongs_to :user
  has_many :comments

  scope :past, where("updated_at < ?", Date.today.beginning_of_day.utc)
  scope :today, lambda { 
    where("updated_at >= ? and updated_at <= ?", 
           Date.today.beginning_of_day.utc, Date.today.end_of_day.utc)
  }
  default_scope order: 'updated_at desc'
  
  attr_accessible :content, :subject

  validates :subject, presence: true, length: { maximum: 50 }
  validates :content, presence: true
  validates :user_id, presence: true
end
