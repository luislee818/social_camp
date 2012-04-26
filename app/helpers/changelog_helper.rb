module ChangelogHelper
  ACTION_VERBS = {
  	ActionType::ADD => "added",
  	ActionType::UPDATE => "updated",
  	ActionType::DESTROY => "deleted"
  }

  DISPLAY_TITLE_MAX_LENGTH = 60

  def log_change(trackable_object, action_type)
  	raise "invalid action_type: #{action_type}" unless ActionType::All.include? action_type

  	changelog = trackable_object.changelogs.build user_id: current_user.id, 
                                                  action_type_id: action_type

    changelog.destroyed_content_summary = trackable_object.final_words if action_type == ActionType::DESTROY

    changelog.save
  end

  def log_add(trackable_object)
    log_change trackable_object, ActionType::ADD
  end

  def log_update(trackable_object)
    log_change trackable_object, ActionType::UPDATE
  end

  def log_destroy(trackable_object)
    log_change trackable_object, ActionType::DESTROY
  end

  def display_mini_log(log)
  	verb = ACTION_VERBS[log.action_type_id]
  	time = time_ago_in_words log.created_at
  	user = User.find_by_id log.user_id
  	
  	"#{verb.capitalize} #{time} ago by #{user.name}" unless user.nil?
  end

  def display_full_log(log, options = { show_user: true })
    user = User.find_by_id log.user_id
    
    unless user.nil?
      verb = ACTION_VERBS[log.action_type_id]
      time = time_ago_in_words log.created_at
      username = sanitize user.name
      trackable_type = log.trackable_type

      if log.trackable.nil? # trackable object had been deleted
        destroy_log = log.get_destroy_log_for_trackable

        display_title = destroy_log.destroyed_content_summary
        trackable_link = display_title
      else
        display_title = truncate((sanitize log.trackable.display_title), length: DISPLAY_TITLE_MAX_LENGTH)
        trackable_link = link_to(display_title, log.trackable)
      end

      if options[:show_user]
        "#{gravatar_for user, size: 18}
         #{link_to username, user}
         #{verb}
         #{trackable_type.downcase}
         #{trackable_link}
         <span class='timestamp'>#{time}&nbsp;ago</span>"
      else
        "#{verb.capitalize}
         #{trackable_type.downcase}
         #{trackable_link}
         <span class='timestamp'>#{time}&nbsp;ago</span>"
      end

      
     end

  end

end