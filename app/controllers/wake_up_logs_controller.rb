class WakeUpLogsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_challenge

  def create
    # 作成者または参加者以外は起床ボタンを実行できない
    unless @challenge.can_wake_up?(current_user)
      respond_to do |format|
        format.turbo_stream { head :forbidden }
        format.html { redirect_to @challenge, alert: "作成者または参加者のみ実行できます" }
      end
      return
    end

    # 起床判定の時間外（例: ready 以外）は弾く
    unless @challenge.ready?
      respond_to do |format|
        format.turbo_stream do
          flash.now[:alert] = "まだ起床判定の時間ではありません"
          render turbo_stream: turbo_stream.replace(
            "action_area_challenge_#{@challenge.id}",
            partial: "challenges/action_area",
            locals: { challenge: @challenge }
          )
        end
        format.html { redirect_to @challenge, alert: "まだ起床判定の時間ではありません" }
      end
      return
    end

    WakeUpLog.create!(
      user: current_user,
      challenge: @challenge,
      status: :success,
      pressed_at: Time.current
    )

    # 状態や表示が変わる可能性があるので最新化
    @challenge.reload

    respond_to do |format|
      format.turbo_stream do
        flash.now[:notice] = "起床を記録しました！"
        render turbo_stream: turbo_stream.replace(
          "action_area_challenge_#{@challenge.id}",
          partial: "challenges/action_area",
          locals: { challenge: @challenge }
        )
      end
      format.html { redirect_to @challenge, notice: "起床を記録しました！" }
    end

    participation = current_user.participations.find_by!(challenge_id: params[:challenge_id])
    # participation.update!(wake_up_at: Time.current)
  end

  private

  def set_challenge
    @challenge = Challenge.find(params[:challenge_id])
  end
end
