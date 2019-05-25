class RssFeeds
  def self.import
    list_of_feed_urls = Rails.application.credentials.rss_feeds
    list_of_feed_urls.each do |feed|
      Importer.new(source_url: feed)
    end
  end
end
