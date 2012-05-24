module ProgressesHelper
	include ERB::Util
	include ApplicationHelper
  include UsersHelper

  ACTION_VERBS = {
  	ActionType::ADD => "added",
  	ActionType::UPDATE => "updated",
  	ActionType::DESTROY => "deleted"
  }

  DISPLAY_TITLE_MAX_LENGTH = 60

  def log_add(trackable_object)
    log_change trackable_object, ActionType::ADD, current_user.id
  end

  def log_update(trackable_object)
    log_change trackable_object, ActionType::UPDATE, current_user.id
  end

  def log_destroy(trackable_object)
    log_change trackable_object, ActionType::DESTROY, current_user.id
  end

  def display_mini_log(log)
  	verb = ACTION_VERBS[log.action_type_id]
  	time = time_ago_in_words log.created_at
  	user = User.find_by_id log.user_id
  	
  	"#{verb.capitalize} #{time} ago by #{user.name}" unless user.nil?
  end

  def display_full_log(log, options = {})
    default_options = { show_user: true, show_relative_timestamp: true }
    options = default_options.merge(options)
    
    user = User.find_by_id log.user_id
    
    unless user.nil?
      verb = ACTION_VERBS[log.action_type_id]
      time = time_ago_in_words log.created_at
      username = user.name
      trackable_type = log.trackable_type
      
      if options[:show_relative_timestamp]
        timestamp = "<span class='timestamp'>#{time_ago_in_words log.created_at}&nbsp;ago</span>"
      else
        timestamp = "<span class='timestamp'>on&nbsp;#{log.created_at}</span>"
      end

      if log.trackable.nil? # trackable object had been deleted
        destroy_log = log.get_destroy_log_for_trackable

        display_title = destroy_log.destroyed_content_summary
        trackable_link = html_escape display_title
      else
        display_title = truncate(log.trackable.display_title, length: DISPLAY_TITLE_MAX_LENGTH)
        trackable_link = link_to(display_title, polymorphic_url(log.trackable))  # need absolute url for RSS feeds
      end

      if options[:show_user]
        "#{gravatar_for user, size: 18}\
         #{link_to username, url_for(controller: 'users', action: 'show', id: user.id, only_path: false)}\
         #{verb}\
         #{trackable_type.downcase}\
         #{trackable_link}\
         #{timestamp}".html_safe
      else
        "#{verb.capitalize}\
         #{trackable_type.downcase}\
         #{trackable_link}\
         #{timestamp}".html_safe
      end
     end
  end
  
  def display_text_log(log)
    user = User.find_by_id log.user_id
    
    unless user.nil?
      verb = ACTION_VERBS[log.action_type_id]
      username = user.name
      trackable_type = log.trackable_type

      if log.trackable.nil? # trackable object had been deleted
        destroy_log = log.get_destroy_log_for_trackable

        display_title = destroy_log.destroyed_content_summary
      else
        display_title = truncate(log.trackable.display_title, length: DISPLAY_TITLE_MAX_LENGTH)
      end

      "#{username}
       #{verb}
       #{trackable_type.downcase}
       #{display_title}"
     end
  end
  
  def get_trackable_url(log)
    return nil if log.trackable.nil?
    
    case log.trackable_type
    when TrackableType::DISCUSSION, TrackableType::COMMENT
      discussion_url(log.trackable_id)
    when TrackableType::EVENT
      event_url(log.trackable_id)
    else
      ''
    end
  end

  private

    def log_change(trackable_object, action_type, user_id)
      raise "invalid action_type: #{action_type}" unless ActionType::All.include? action_type

      changelog = trackable_object.changelogs.build user_id: user_id, 
                                                    action_type_id: action_type

      changelog.destroyed_content_summary = trackable_object.final_words if action_type == ActionType::DESTROY

      changelog.save

      changelog
    end
end
