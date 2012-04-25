class Event < ActiveRecord::Base
  belongs_to :user
  has_many :changelogs, as: :trackable, dependent: :destroy

  scope :upcoming, where("start_at > ?", Time.now).order('start_at asc')
  scope :past, where("start_at < ?", Time.now).order('start_at desc')
  scope :today, lambda { 
    where("start_at >= ? and start_at <= ?", 
           Date.today.beginning_of_day.utc, Date.today.end_of_day.utc)
    .order('start_at asc')
  }
  
  attr_accessible :description, :location, :name, :start_at
  validates :name, presence: true
  validates :start_at, presence: true
  validates :user_id, presence: true
end
