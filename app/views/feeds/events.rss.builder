xml.instruct!
xml.rss "version" => "2.0",
          "xmlns:dc" => "http://purl.org/dc/elements/1.1/" do
  xml.channel do
    xml.title 'SocialCamp - Events Updates'
    xml.link events_url
    xml.pubDate CGI.rfc1123_date(@event_updates.first.updated_at)
    xml.description h("Latest 20 event updates on SocialCamp")
    @event_updates.each do |event_update|
      xml.item do
        xml.title display_text_log(event_update)
        xml.link event_url(event_update.trackable)
        xml.description display_full_log(event_update)
        xml.pubDate CGI.rfc1123_date(event_update.updated_at)
        xml.guid event_update.id, { isPermaLink: false }
        xml.author "#{event_update.user.email} (#{h event_update.user.name})"
      end
    end
  end
end