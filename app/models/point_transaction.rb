class PointTransaction < ApplicationRecord
  belongs_to :user
  belongs_to :source, polymorphic: true

  # ポイント付与理由
  enum reason: {
    solo_success: 0,
    multi_success: 1
  }

  validates :points, numericality: { greater_than_or_equal_to: 0 }
  validates :reason, presence: true
  validates :target_date, presence: true
end
