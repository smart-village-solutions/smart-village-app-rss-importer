class Importer
  attr_accessor :access_token, :current_user, :feed

  # Steps for Importer
  # - Load Login Credentials from server
  # - Load xml Data from tmb-url
  # - Parse XML Data to Hash
  # - send JSON Data to server
  # - save response from server an log it
  # - send notifications
  def initialize(feed: nil)
    @feed = feed

    @record = Record.new(source_url: @feed[:url], feed: @feed)
    @record.load_rss_data
    @record.convert_rss_to_hash
    send_json_to_server
  end

  def send_json_to_server
    access_token = Authentication.new(feed: @feed).access_token
    base_url = Rails.application.credentials.target_server[:url]
    url = "#{base_url}/"

    begin
      result = ApiRequestService.new(url, nil, nil, @record.json_data, {Authorization: "Bearer #{access_token}"}).post_request
      @record.update(updated_at: Time.now, audit_comment: result.body)
    rescue => e
      @record.update(updated_at: Time.now, audit_comment: e)
      Rollbar.error("API Request Error.", full_message: e)
    end
  end
end
