class OauthController < ApplicationController
  def confirm_access
    auth = Authentication.new.load_access_tokens(code: params[:code], grant_type: "authorization_code")

    render html: "Access Code received: #{auth}"
  end
end
