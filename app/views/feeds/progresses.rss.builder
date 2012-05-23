xml.instruct!
xml.rss "version" => "2.0",
          "xmlns:dc" => "http://purl.org/dc/elements/1.1/" do
  xml.channel do
    xml.title 'SocialCamp - All Updates'
    xml.link progress_url
    xml.pubDate CGI.rfc1123_date(@changelogs.first ? @changelogs.first.updated_at : Time.now)
    xml.description h("Latest 20 event updates on SocialCamp")
    @changelogs.each do |changelog|
      xml.item do
        xml.title display_text_log(changelog)
        xml.link get_trackable_url(changelog) if get_trackable_url(changelog)
        xml.description display_full_log(changelog, show_relative_timestamp: false)
        xml.pubDate CGI.rfc1123_date(changelog.updated_at)
        xml.guid changelog.id, { isPermaLink: false }
        xml.author "#{changelog.user.email} (#{h changelog.user.name})"
      end
    end
  end
end