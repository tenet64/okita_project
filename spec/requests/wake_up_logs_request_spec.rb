require "rails_helper"

RSpec.describe "WakeUpLogs", type: :request do
  let(:user) { create(:user) }
  let(:turbo_headers) { { "ACCEPT" => "text/vnd.turbo-stream.html" } }

  before do
    sign_in user
  end

  describe "POST /challenges/:challenge_id/wake_up_logs" do
    it "rejects non-member on html request" do
      target_at = 1.minute.from_now
      challenge = create(
        :challenge,
        :multi,
        user: create(:user),
        target_date: target_at.to_date,
        target_time: target_at,
        capacity: 3,
        status: :ready
      )

      expect do
        post challenge_wake_up_logs_path(challenge)
      end.not_to change(WakeUpLog, :count)

      expect(response).to redirect_to(challenge_path(challenge))
      expect(flash[:alert]).to eq("作成者または参加者のみ実行できます")
    end

    it "creates wake up log for eligible user on html request" do
      target_at = 1.minute.from_now
      challenge = create(
        :challenge,
        user: user,
        mode: :solo,
        status: :ready,
        target_date: target_at.to_date,
        target_time: target_at
      )

      expect do
        post challenge_wake_up_logs_path(challenge)
      end.to change(WakeUpLog, :count).by(1)

      expect(response).to redirect_to(challenge_path(challenge))
      expect(flash[:notice]).to eq("起床を記録しました！")
      expect(WakeUpLog.last).to be_success
    end

    it "returns forbidden for non-member on turbo_stream request" do
      target_at = 1.minute.from_now
      challenge = create(
        :challenge,
        :multi,
        user: create(:user),
        target_date: target_at.to_date,
        target_time: target_at,
        capacity: 3,
        status: :ready
      )

      post challenge_wake_up_logs_path(challenge), headers: turbo_headers

      expect(response).to have_http_status(:forbidden)
    end

    it "returns turbo_stream response for eligible user" do
      target_at = 1.minute.from_now
      challenge = create(
        :challenge,
        user: user,
        mode: :solo,
        status: :ready,
        target_date: target_at.to_date,
        target_time: target_at
      )

      expect do
        post challenge_wake_up_logs_path(challenge), headers: turbo_headers
      end.to change(WakeUpLog, :count).by(1)

      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      expect(response.body).to include("action_area_challenge_#{challenge.id}")
    end
  end
end
