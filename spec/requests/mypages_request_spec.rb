require "rails_helper"

RSpec.describe "Mypages", type: :request do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  describe "GET /mypage" do
    it "returns success" do
      get mypage_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /mypage/edit" do
    it "returns success" do
      get edit_mypage_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /mypage" do
    it "updates profile with valid params" do
      patch mypage_path, params: { user: { name: "更新後ユーザー", email: "updated@example.com" } }

      expect(response).to redirect_to(mypage_path)
      expect(flash[:notice]).to eq("プロフィールを更新しました")
      expect(user.reload.name).to eq("更新後ユーザー")
      expect(user.email).to eq("updated@example.com")
    end

    it "renders edit with unprocessable_entity on invalid params" do
      patch mypage_path, params: { user: { name: "", email: "invalid@example.com" } }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(user.reload.name).not_to eq("")
    end
  end

  describe "GET /mypage/calendar" do
    it "returns success with start_date param" do
      get calendar_mypage_path, params: { start_date: Date.current.to_s }
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /mypage/graph" do
    it "returns success with start_date param" do
      get graph_mypage_path, params: { start_date: Date.current.to_s }
      expect(response).to have_http_status(:ok)
    end

    it "returns success without start_date param" do
      get graph_mypage_path
      expect(response).to have_http_status(:ok)
    end
  end
end
