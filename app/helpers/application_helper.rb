module ApplicationHelper
  def full_title(page_title)
    full_title = "SocialCamp"
    if page_title.empty?
      full_title
    else
      "#{full_title} | #{page_title}"
    end
  end
end
