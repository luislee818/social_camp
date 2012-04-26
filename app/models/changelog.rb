class Changelog < ActiveRecord::Base
  belongs_to :trackable, polymorphic: true
  belongs_to :user
  
  attr_accessible :action_type_id, :trackable_id, :trackable_type, :user_id

  default_scope order: 'created_at DESC'

  validates :user_id, presence: true
  validates :action_type_id, presence: true
  validates :trackable_id, presence: true
  validates :trackable_type, presence: true

  def self.of_trackable(trackable_object)
    Changelog.find_all_by_trackable_type_and_trackable_id(
                            trackable_object.class.to_s, 
                            trackable_object.id)
              .sort_by { |t| t.created_at }
  end

  def get_destroy_log_for_trackable
  	destroy_log = Changelog.where('trackable_type = :trackable_type and trackable_id = :trackable_id and action_type_id = :action_type_id', 
  									trackable_type: trackable_type,
  									trackable_id: trackable_id,
  									action_type_id: ActionType::DESTROY)
  							.last
  end
end
