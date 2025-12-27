class WakeUpLog < ApplicationRecord
  belongs_to :user
  belongs_to :challenge

  after_create :judge_challenge

  private
  def judge_challenge
    challenge.judge!
  end
end
