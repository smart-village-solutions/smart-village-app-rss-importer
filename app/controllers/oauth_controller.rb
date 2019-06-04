class OauthController < ApplicationController
  def confirm_access
    auth = Authentication.new.load_access_tokens

    render html: "Access Code received: #{auth}"
  end
end
