class Importer
  attr_accessor :access_token, :current_user

  # Steps for Importer
  # - Load Login Credentials from server
  # - Load xml Data from tmb-url
  # - Parse XML Data to Hash
  # - send JSON Data to server
  # - save response from server an log it
  # - send notifications
  def initialize(source_url: nil)
    load_user_data

    if @current_user.present?
      @record = Record.new(current_user: @current_user, source_url: source_url)
      @record.load_rss_data
      @record.convert_rss_to_hash
      send_json_to_server
    end
  end

  def load_user_data
    access_token = Authentication.new.access_token
    base_url = Rails.application.credentials.auth_server[:url]
    url = "#{base_url}/data_provider.json"

    begin
      result = ApiRequestService.new(url, nil, nil, nil, {Authorization: "Bearer #{access_token}"}).get_request
      @current_user = JSON.parse(result.body)
    rescue => e
      @current_user = { data_provider: { } }
    end
  end

  def send_json_to_server
    access_token = Authentication.new.access_token
    base_url = Rails.application.credentials.target_server[:url]
    url = "#{base_url}/"

    begin
      result = ApiRequestService.new(url, nil, nil, @record.json_data, {Authorization: "Bearer #{access_token}"}).post_request
      @record.update(updated_at: Time.now, audit_comment: result.body)
    rescue => e
      @record.update(updated_at: Time.now, audit_comment: e)
    end
  end
end
