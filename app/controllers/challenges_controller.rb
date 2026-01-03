class ChallengesController < ApplicationController
    before_action :set_challenge, only: [ :show, :edit, :update, :destroy ]
    before_action :authenticate_user!, only: [ :index, :show, :new, :create, :edit, :update, :destroy ]

    # GET /challenges
    def index
        @challenges = Challenge
      .includes(:participations, :user)
      .where("target_date >= ?", Date.current)
      .order(:target_date, :target_time)
    end

    # GET /challenges/1
    def show
        @participants = @challenge.participations.includes(:user)
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
end
