module DiscussionsHelper
  ALLOWED_TAGS_IN_COMMENT = %w(p br)
  
  def sanitize_content(content)
    sanitize (simple_format content), tags: ALLOWED_TAGS_IN_COMMENT
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
end
