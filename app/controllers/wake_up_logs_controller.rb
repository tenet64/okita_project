class WakeUpLogsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_challenge

  def create
    if @challenge.ready?
      WakeUpLog.create!(
        user: current_user,
        challenge: @challenge,
        status: :success,
        pressed_at: Time.current
      )
      redirect_to @challenge, notice: "起床を記録しました！"
    else
      redirect_to @challenge, alert: "まだ起床判定の時間ではありません"
    end
  end

  private

  def set_challenge
    @challenge = Challenge.find(params[:challenge_id])
  end
end