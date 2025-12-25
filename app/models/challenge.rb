class Challenge < ApplicationRecord
  enum mode: { solo: 1, multi: 2 }
  belongs_to :user
  has_many :participations, dependent: :destroy

  validates :title, presence: true
  validates :target_date, presence: true
  validates :target_time, presence: true
end
