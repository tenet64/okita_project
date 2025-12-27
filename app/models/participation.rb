class Participation < ApplicationRecord
  belongs_to :user
  belongs_to :challenge

  validate :challenge_not_full
  validates :user_id, uniqueness: { scope: :challenge_id }
  validate :challenge_not_full

  after_create :mark_challenge_ready_if_filled

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
end
