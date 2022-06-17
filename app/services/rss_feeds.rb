class RssFeeds

  DASHBOARD_URL="https://dashboard.smart-village.app/api/v1/settings"

  class DashboardProjectDoesNotExistError < StandardError;
    def initialize
      super("Dashboard didn't respond with data. Check dashboard_project_id for #{ENV['SVA_COMMUNITY']}.")
    end
  end

  def self.import
    begin
      url = "#{DASHBOARD_URL}/#{ReleaseSettings.dashboard_project_id}"
      response = ApiRequestService.new(url, nil, nil, nil, {}).get_request.try(:body)

      # TODO: Fix maybe put a more reasonable response into the
      # Dashboard's api
      raise DashboardProjectDoesNotExistError.new if response == "null"

      response = JSON.parse(response).with_indifferent_access
      list_of_feed_urls = response["rss_feeds"]
    rescue StandardError => e
      Rails.logger.error "Failed to fetch feeds: #{e.message}"
      Rails.logger.error e.backtrace.first
      list_of_feed_urls = []
    end

    list_of_feed_urls.each do |feed|
      begin
        Importer.new(feed: feed)
      rescue => e
        Rails.logger.error "Feed #{feed[:name]} #{feed[:url]} fehlgeschlagen: #{e.message}"
      end
    end
  end
end
