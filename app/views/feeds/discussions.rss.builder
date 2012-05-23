xml.instruct!
xml.rss "version" => "2.0",
          "xmlns:dc" => "http://purl.org/dc/elements/1.1/" do
  xml.channel do
    xml.title 'SocialCamp - New Discussions'
    xml.link discussions_url
    xml.pubDate CGI.rfc1123_date(@discussions.first ? @discussions.first.updated_at : Time.now)
    xml.description h("Latest 20 discussions on SocialCamp")
    @discussions.each do |discussion|
      xml.item do
        xml.title h(discussion.subject)
        xml.link discussion_url(discussion)
        xml.description sanitize_allow_minimal_html(discussion.content)
        xml.pubDate CGI.rfc1123_date(discussion.updated_at)
        xml.guid discussion_url(discussion)
        xml.author "#{discussion.user.email} (#{h discussion.user.name})"
      end
    end
  end
end