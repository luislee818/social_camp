class Event < ActiveRecord::Base
  belongs_to :user

  scope :upcoming, where("start_at > ?", Time.now)
  scope :past, where("start_at < ?", Time.now)
  scope :today, lambda { 
    where("start_at >= ? and start_at <= ?", 
           Date.today.beginning_of_day.utc, Date.today.end_of_day.utc)
  }
  default_scope order: 'start_at desc'
  
  attr_accessible :description, :location, :name, :start_at
  validates :name, presence: true
  validates :start_at, presence: true
  validates :user_id, presence: true
end
