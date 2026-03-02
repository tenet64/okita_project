require "rails_helper"

RSpec.describe "Participations", type: :request do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  describe "POST /challenges/:challenge_id/participations" do
    it "rejects participation for solo challenge" do
      challenge = create(:challenge, user: create(:user), mode: :solo, status: :ready, target_date: Date.tomorrow)

      expect do
        post challenge_participations_path(challenge)
      end.not_to change(Participation, :count)

      expect(response).to redirect_to(challenge_path(challenge))
      expect(flash[:alert]).to eq("ソロチャレンジには参加できません")
    end

    it "creates participation for multi challenge" do
      challenge = create(:challenge, :multi, user: create(:user), capacity: 3, status: :recruiting, target_date: Date.tomorrow)

      expect do
        post challenge_participations_path(challenge)
      end.to change(Participation, :count).by(1)

      expect(response).to redirect_to(challenge_path(challenge))
      expect(flash[:notice]).to eq("チャレンジに参加しました")
    end

    it "shows validation error when already participating" do
      challenge = create(:challenge, :multi, user: create(:user), capacity: 3, status: :recruiting, target_date: Date.tomorrow)
      create(:participation, user: user, challenge: challenge)

      expect do
        post challenge_participations_path(challenge)
      end.not_to change(Participation, :count)

      expect(response).to redirect_to(challenge_path(challenge))
      expect(flash[:alert]).to be_present
    end
  end

  describe "DELETE /challenges/:challenge_id/participations/:id" do
    it "cancels own participation" do
      challenge = create(:challenge, :multi, user: create(:user), capacity: 3, status: :recruiting, target_date: Date.tomorrow)
      participation = create(:participation, user: user, challenge: challenge)

      expect do
        delete challenge_participation_path(challenge, participation)
      end.to change(Participation, :count).by(-1)

      expect(response).to redirect_to(challenge_path(challenge))
      expect(flash[:notice]).to eq("参加をキャンセルしました")
    end
  end
end
