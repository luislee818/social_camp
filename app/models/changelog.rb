class Changelog < ActiveRecord::Base
  belongs_to :trackable, polymorphic: true
  
  attr_accessible :action_type_id, :trackable_id, :trackable_type, :user_id

  default_scope order: 'created_at DESC'

  validates :user_id, presence: true
  validates :action_type_id, presence: true
  validates :trackable_id, presence: true
  validates :trackable_type, presence: true
end
