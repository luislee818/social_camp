module ApplicationHelper
  include ERB::Util

  ALLOWED_TAGS_IN_POSTED_CONTENT = %w(p br)

  def full_title(page_title)
    full_title = "SocialCamp"
    if page_title.blank?
      full_title
    else
      "#{full_title} | #{page_title}"
    end
  end

  def sanitize_allow_minimal_html(content)
    sanitize (simple_format content), tags: ALLOWED_TAGS_IN_POSTED_CONTENT
  end

  def date_is_today(date)
  	date.to_date == Date.today
  end

  def date_is_tomorrow(date)
  	date.to_date == Date.tomorrow
  end

  def date_is_yesterday(date)
  	date.to_date == Date.yesterday
  end

  def strong(content)
    "<strong>#{h content}</strong>".html_safe
  end
end
