class OauthController < ApplicationController
  def confirm_access
    Authentication.new.load_access_tokens(code: params[:code], grant_type: "authorization_code")

    render html: "Access Code saved"
  end
end
