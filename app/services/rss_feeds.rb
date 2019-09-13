class RssFeeds
  def self.import
    list_of_feed_urls = Rails.application.credentials.rss_feeds
    list_of_feed_urls.each do |feed|
      Importer.new(feed: feed)
      Rails.logger.notify!(short_message: "Feed imported", full_message: feed[:url])
    end
  end
end
