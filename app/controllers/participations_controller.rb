class ParticipationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_challenge

  def create
    @challenge.participations.create(user: current_user)
    redirect_to @challenge
  end

  private

  def set_challenge
    @challenge = Challenge.find(params[:challenge_id])
  end
end
