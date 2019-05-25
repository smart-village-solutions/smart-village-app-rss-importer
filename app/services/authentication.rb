class Authentication
  attr_accessor :setting

  def initialize
    @setting = Setting.new
  end

  def load_access_tokens(code: nil, grant_type: "authorization_code")
    auth_server = Rails.application.credentials.auth_server[:url]
    uri = Addressable::URI.parse("#{auth_server}/oauth/token")
    uri.query_values = {
      client_id: Rails.application.credentials.auth_server[:key],
      client_secret: Rails.application.credentials.auth_server[:secret],
      redirect_uri: Rails.application.credentials.auth_server[:callback_url],
      grant_type: grant_type
    }

    case grant_type
    when "authorization_code"
      auth_code = { code: code }
    when "refresh_token"
      auth_code = { refresh_token: setting.config["oauth"]["refresh_token"] }
    end

    uri.query_values = uri.query_values.merge(auth_code)

    result = ApiRequestService.new(uri.to_s, nil, nil, uri.query_values).post_request

    if result.code == "200" && result.body.present?
      data = JSON.parse(result.body)
      save_tokens(data)
    else
      p result.body
    end
  end

  def save_tokens(token_hash)
    setting.config["oauth"] = {} if setting.config["oauth"].blank?
    setting.config["oauth"]["access_token"] = token_hash.fetch("access_token", "")
    setting.config["oauth"]["refresh_token"] = token_hash.fetch("refresh_token", "")
    setting.config["oauth"]["expires_in"] = token_hash.fetch("expires_in", "")
    setting.config["oauth"]["created_at"] = token_hash.fetch("created_at", "")
    setting.save
  end

  def access_token
    load_access_tokens(grant_type: "refresh_token")
    setting.config["oauth"]["access_token"]
  end

  def authorized?
    setting.config["oauth"]["refresh_token"].present?
  end

end
