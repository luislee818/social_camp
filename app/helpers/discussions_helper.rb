module DiscussionsHelper
  ALLOWED_TAGS_IN_COMMENT = %w(p br)
  
  def sanitize_content(content)
    sanitize (simple_format content), tags: ALLOWED_TAGS_IN_COMMENT
  end
end
