require "rails_helper"

RSpec.describe "Challenges", type: :request do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  def valid_params(overrides = {})
    {
      challenge: {
        title: "朝活チャレンジ",
        target_date: Date.tomorrow,
        target_time: "06:30",
        mode: "solo",
        capacity: nil
      }.merge(overrides)
    }
  end

  describe "GET /challenges/new" do
    it "returns success" do
      get new_challenge_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /challenges" do
    it "creates a solo challenge as ready" do
      expect do
        post challenges_path, params: valid_params
      end.to change(Challenge, :count).by(1)

      created = Challenge.order(:created_at).last
      expect(created).to be_ready
      expect(response).to redirect_to(challenge_path(created))
      expect(flash[:notice]).to eq("チャレンジを作成しました")
    end

    it "creates host participation when mode is multi" do
      expect do
        post challenges_path, params: valid_params(mode: "multi", capacity: 2)
      end.to change(Challenge, :count).by(1)
        .and change(Participation, :count).by(1)

      created = Challenge.order(:created_at).last
      expect(created).to be_multi
      expect(created.participations.where(user_id: user.id)).to exist
    end

    it "renders new with unprocessable_entity when invalid" do
      expect do
        post challenges_path, params: valid_params(title: nil)
      end.not_to change(Challenge, :count)

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "DELETE /challenges/:id" do
    it "destroys own challenge when target time is more than 60 minutes away" do
      target_at = 2.hours.from_now
      challenge = create(
        :challenge,
        user: user,
        target_date: target_at.to_date,
        target_time: target_at,
        mode: :solo,
        status: :ready
      )

      expect do
        delete challenge_path(challenge)
      end.to change(Challenge, :count).by(-1)

      expect(response).to redirect_to(challenges_path)
      expect(flash[:notice]).to eq("削除しました")
    end

    it "does not destroy own challenge when target time is within 60 minutes" do
      target_at = 30.minutes.from_now
      challenge = create(
        :challenge,
        user: user,
        target_date: target_at.to_date,
        target_time: target_at,
        mode: :solo,
        status: :ready
      )

      expect do
        delete challenge_path(challenge)
      end.not_to change(Challenge, :count)

      expect(response).to redirect_to(challenge_path(challenge))
      expect(flash[:alert]).to include("60分前")
    end

    it "redirects to authenticated root when non-owner tries to destroy" do
      owner = create(:user)
      target_at = 2.hours.from_now
      challenge = create(
        :challenge,
        user: owner,
        target_date: target_at.to_date,
        target_time: target_at,
        mode: :solo,
        status: :ready
      )

      expect do
        delete challenge_path(challenge)
      end.not_to change(Challenge, :count)

      expect(response).to redirect_to(authenticated_root_path)
    end
  end
end
