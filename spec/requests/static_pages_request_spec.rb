require "rails_helper"

RSpec.describe "StaticPages", type: :request do
  describe "GET /how_to_use" do
    it "returns success when logged in" do
      sign_in create(:user)
      get how_to_use_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /terms" do
    it "returns success" do
      get terms_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /privacy" do
    it "returns success" do
      get privacy_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /contact" do
    it "returns success" do
      get contact_path
      expect(response).to have_http_status(:ok)
    end
  end
end
