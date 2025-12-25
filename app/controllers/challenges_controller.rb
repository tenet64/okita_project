class ChallengesController < ApplicationController
    before_action :set_challenge, only: [ :show, :edit, :update, :destroy ]

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
        @joined = @participants.any? { |p| p.user_id == current_user.id }
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

        if @challenge.save
            redirect_to @challenge, notice: "Challenge was successfully created."
        else
        render :new
        end
    end

    # PATCH/PUT /challenges/1
    def update
        if @challenge.update(challenge_params)
        redirect_to @challenge, notice: "Challenge was successfully updated."
        else
        render :edit
        end
    end

    # DELETE /challenges/1
    def destroy
        @challenge.destroy
        redirect_to challenges_url, notice: "Challenge was successfully destroyed."
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
