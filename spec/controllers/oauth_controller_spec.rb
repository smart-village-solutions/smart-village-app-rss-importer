require 'rails_helper'

RSpec.describe OauthController, type: :controller do

  describe "GET #confirm_access" do
    it "returns http success" do
      get :confirm_access
      expect(response).to have_http_status(:success)
    end
  end

end
