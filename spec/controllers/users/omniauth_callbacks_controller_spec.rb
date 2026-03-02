require "rails_helper"
require "omniauth"

RSpec.describe Users::OmniauthCallbacksController, type: :controller do
  let(:auth_hash) do
    OmniAuth::AuthHash.new(
      provider: "google_oauth2",
      uid: "uid-123",
      info: {
        name: "OAuth User",
        email: "oauth-user@example.com"
      },
      extra: {
        raw_info: {
          sub: "uid-123"
        }
      }
    )
  end

  before do
    request.env["devise.mapping"] = Devise.mappings[:user]
    request.env["omniauth.auth"] = auth_hash
  end

  describe "GET #google_oauth2" do
    it "redirects to authenticated root when user is persisted" do
      user = create(:user, :google_user, uid: "uid-123", email: "oauth-user@example.com")
      allow(User).to receive(:from_omniauth).and_return(user)

      get :google_oauth2

      expect(response).to redirect_to(authenticated_root_path)
    end

    it "stores omniauth data and redirects to sign up when user is not persisted" do
      allow(User).to receive(:from_omniauth).and_return(User.new)

      get :google_oauth2

      expect(response).to redirect_to(new_user_registration_url)
      stored = session["devise.google_data"]
      expect(stored["provider"] || stored[:provider]).to eq("google_oauth2")
      expect(stored["uid"] || stored[:uid]).to eq("uid-123")
      expect(stored).not_to have_key("extra")
      expect(stored).not_to have_key(:extra)
    end
  end

end
