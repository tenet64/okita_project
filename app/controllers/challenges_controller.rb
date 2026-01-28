class ChallengesController < ApplicationController
    before_action :set_challenge, only: [ :show, :edit, :update, :destroy ]
    before_action :authenticate_user!, only: [ :index, :show, :new, :create, :edit, :update, :destroy ]
    before_action :correct_challenge, only: [ :edit, :update, :destroy ]
    before_action :prevent_destroy_if_close, only: [ :destroy ]

   # GET /challenges
   def index
     now = Time.zone.now

    @challenges = Challenge
    .includes(:participations, :user)
    .where(
      "(target_date > :today) OR (target_date = :today AND target_time >= :current_time)",
      today: now.to_date,
      current_time: now.strftime("%H:%M:%S")
    )
    .order(:target_date, :target_time)
   end

    # GET /challenges/1
    def show
        @participants = @challenge.participations.includes(:user)
        @challenge.finalize_recruiting_if_due!
        @challenge.refresh_status_by_logs!(date: @challenge.target_date)
    end

    # GET /challenges/new
    def new
        @challenge = Challenge.new
    end

    # GET /challenges/1/edit
    def edit
    end

    # POST /challenges
    def create
      @challenge = current_user.challenges.build(challenge_params)

      ActiveRecord::Base.transaction do
        # ソロは即 ready
        if @challenge.solo?
          @challenge.status = :ready
        end

        @challenge.save!

        # マルチの場合はホストを参加者として登録
        if @challenge.multi?
          Participation.create!(
            user: current_user,
            challenge: @challenge
          )
        end
      end

      redirect_to @challenge, notice: "チャレンジを作成しました"
    rescue ActiveRecord::RecordInvalid
      render :new, status: :unprocessable_entity
    end

    # PATCH/PUT /challenges/1
    def update
        if @challenge.update(challenge_params)
        redirect_to @challenge, notice: "更新しました"
        else
        render :edit
        end
    end

    # DELETE /challenges/1
    def destroy
        @challenge.destroy
        redirect_to challenges_url, notice: "削除しました"
    end

    private

    def set_challenge
        @challenge = Challenge.find(params[:id])
    end

    def challenge_params
        params.require(:challenge).permit(
            :title,
            :target_date,
            :target_time,
            :mode,
            :capacity
          )
    end

    def correct_challenge
      unless @challenge.user_id == current_user.id
        redirect_to authenticated_root_path
      end
    end

    def prevent_destroy_if_close
      # target_date + target_time から起床時刻を作る
      target_at =
        Time.zone.local(
      @challenge.target_date.year,
      @challenge.target_date.month,
      @challenge.target_date.day,
      @challenge.target_time.hour,
      @challenge.target_time.min
    )

      # 60分を切っていたら削除不可
      if Time.zone.now >= target_at - 60.minutes
        redirect_to challenge_path(@challenge),
                    alert: "起床時刻の60分前を過ぎているため、このチャレンジは削除できません"
      end
    end
end
