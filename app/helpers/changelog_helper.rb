module ChangelogHelper
  ACTION_VERBS = {
  	ActionType::ADD => "added",
  	ActionType::UPDATE => "updated",
  	ActionType::DESTROY => "destroyed"
  }

  def log_change(trackable_object, action_type)
  	raise "invalid action_type: #{action_type}" unless ActionType::All.include? action_type

  	changelog = trackable_object.changelogs.build user_id: current_user.id, 
                                                  action_type_id: action_type
    changelog.save
  end

  def display_log(log)
  	verb = ACTION_VERBS[log.action_type_id]
  	time = time_ago_in_words log.created_at
  	user = User.find_by_id log.user_id
  	
  	"#{verb.capitalize} #{time} ago by #{user.name}" unless user.nil?
  end

end