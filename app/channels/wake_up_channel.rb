class WakeUpChannel < ApplicationCable::Channel
  def subscribed
    stream_from "challenge_#{params[:challenge_id]}_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
