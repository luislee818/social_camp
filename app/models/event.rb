class Event < ActiveRecord::Base
  include FinalWordsCollector

  belongs_to :user
  has_many :changelogs, as: :trackable, dependent: :destroy

  scope :upcoming, where("start_at > ?", Time.now).order('start_at asc')
  scope :past, where("start_at < ?", Time.now).order('start_at desc')
  
  attr_accessible :description, :location, :name, :start_at
  validates :name, presence: true, length: { maximum: 100 }
  validates :start_at, presence: true
  validates :user_id, presence: true

  def display_title
    name
  end

end
