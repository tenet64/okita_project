class Participation < ApplicationRecord
  belongs_to :user
  belongs_to :challenge

  validate :challenge_not_full
  validates :user_id, uniqueness: { scope: :challenge_id }

  after_create :mark_challenge_ready_if_filled
  after_update_commit :broadcast_wakeup, if: :saved_change_to_wake_up_at?


  private

  def challenge_not_full
    return unless challenge.multi?

    if challenge.participations.count >= challenge.capacity
      errors.add(:base, "このチャレンジは定員に達しています")
    end
  end

  def mark_challenge_ready_if_filled
    return unless challenge.multi?
    return unless challenge.recruiting?
    return if challenge.capacity.blank?

    if challenge.participations.count >= challenge.capacity
      challenge.update!(status: :ready)
    end
  end

  def broadcast_wakeup
    broadcast_replace_to(
      challenge,
      target: "participation_#{id}",
      partial: "participations/status",
      locals: { participation: self }
    )
  end
end
