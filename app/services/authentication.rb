class Authentication
  attr_accessor :setting, :feed

  def initialize(feed: nil)
    @feed = feed
    @setting = Setting.new
  end

  def load_access_tokens
    auth_server = Rails.application.credentials.auth_server[:url]
    uri = Addressable::URI.parse("#{auth_server}/oauth/token")
    uri.query_values = {
      client_id: @feed[:auth][:key],
      client_secret: @feed[:auth][:secret],
      redirect_uri: Rails.application.credentials.auth_server[:callback_url],
      grant_type: "client_credentials"
    }

    result = ApiRequestService.new(uri.to_s, nil, nil, uri.query_values).post_request

    if result.code == "200" && result.body.present?
      data = JSON.parse(result.body)
      save_tokens(data)
    else
      result.body
    end
  end

  def save_tokens(token_hash)
    key = @feed[:auth][:key]
    setting.config[key] = {} if setting.config[key].blank?
    setting.config[key]["access_token"] = token_hash.fetch("access_token", "")
    setting.config[key]["expires_in"] = token_hash.fetch("expires_in", "")
    setting.config[key]["created_at"] = token_hash.fetch("created_at", "")
    setting.save
  end

  def access_token
    load_access_tokens
    setting.config["oauth"]["access_token"]
  end
end
