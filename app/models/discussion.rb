class Discussion < ActiveRecord::Base
  belongs_to :user
  has_many :comments, dependent: :destroy

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
end
