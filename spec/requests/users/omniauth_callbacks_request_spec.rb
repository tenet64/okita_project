require "rails_helper"

RSpec.describe "Users::OmniauthCallbacks", type: :request do
  describe "GET /auth/failure" do
    it "redirects to root" do
      get "/auth/failure"

      expect(response).to redirect_to("/")
    end
  end
end
