class RssFeeds

  DASHBOARD_URL="https://dashboard.smart-village.app/api/v1/settings"

  def self.import
    begin
      url = "#{DASHBOARD_URL}/#{ReleaseSettings.dashboard_project_id}"
      response = ApiRequestService.new(url, nil, nil, nil, {}).get_request.try(:body)
      response = JSON.parse(response).with_indifferent_access

      list_of_feed_urls = response["rss_feeds"]
    rescue
      list_of_feed_urls = []
    end

    list_of_feed_urls.each do |feed|
      Importer.new(feed: feed)
    end
  end
end
