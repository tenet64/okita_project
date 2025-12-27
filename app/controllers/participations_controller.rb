class ParticipationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_challenge


  def create
    @challenge = Challenge.find(params[:challenge_id])

    # 🔒 solo は参加不可
    if @challenge.solo?
      redirect_to @challenge, alert: "ソロチャレンジには参加できません"
      return
    end

    participation = @challenge.participations.build(user: current_user)

    if participation.save
      redirect_to @challenge, notice: "チャレンジに参加しました"
    else
      redirect_to @challenge, alert: participation.errors.full_messages.first
    end
  end

  def destroy
    participation = @challenge.participations.find_by!(user_id: current_user.id)
    participation.destroy
    redirect_to @challenge, notice: "参加をキャンセルしました"
  end

  private

  def set_challenge
    @challenge = Challenge.find(params[:challenge_id])
  end
end