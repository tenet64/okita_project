class Challenge < ApplicationRecord
  enum mode: { solo: 1, multi: 2 }
  enum status: {
    recruiting: 0,
    ready: 1,
    success: 2,
    failed: 3
  }
  belongs_to :user
  has_many :participations, dependent: :destroy
  has_many :wake_up_logs, dependent: :destroy

  validates :title, presence: true
  validates :target_date, presence: true
  validates :target_time, presence: true
end
