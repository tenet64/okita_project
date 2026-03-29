class WakeUpLogsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_challenge

  # GET /challenges/:challenge_id/wake_up_logs → 詳細へ（ルーティングエラー回避）
  def redirect_to_challenge
    redirect_to @challenge
  end

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

    log = WakeUpLog.create!(
      user: current_user,
      challenge: @challenge,
      status: :success,
      pressed_at: Time.current
    )
   ActionCable.server.broadcast(
      "challenge_#{@challenge.id}_channel",
      {
        user_id: current_user.id,
        user_name: current_user.name,
        message: "#{current_user.name}さんが起床しました！",
        pressed_at: log.pressed_at.strftime("%m/%d %H:%M") # 表示用フォーマット
      }
    )


    # 状態や表示が変わる可能性があるので最新化
    @challenge.reload

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @challenge }
    end
  end

  private

  def set_challenge
    @challenge = Challenge.find(params[:challenge_id])
  end
end
