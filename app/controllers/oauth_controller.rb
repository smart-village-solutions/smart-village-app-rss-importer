class OauthController < ApplicationController
  def confirm_access
    render html: "Access Code received"
  end
end
