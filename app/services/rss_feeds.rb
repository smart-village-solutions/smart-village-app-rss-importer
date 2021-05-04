class RssFeeds
  def self.import
    begin
      server_url = Rails.application.credentials.cronjob_service[:server_url]
      project_id = Rails.application.credentials.cronjob_service[:project_id]
      url = "#{server_url}/api/v1/settings/#{project_id}"
      response = ApiRequestService.new(url, nil, nil, nil, {}).get_request.try(:body)
      response = JSON.parse(response)

      list_of_feed_urls = response["rss_feeds"]
    rescue
      list_of_feed_urls = []
    end

    list_of_feed_urls.each do |feed|
      Importer.new(feed: feed)
    end
  end
end
