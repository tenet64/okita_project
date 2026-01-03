class WakeUpLog < ApplicationRecord
  belongs_to :user
  belongs_to :challenge

  enum status: { success: 0, failure: 1 }
  validates :user_id, uniqueness: { scope: :challenge_id }
end
