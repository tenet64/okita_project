class UserBadge < ApplicationRecord
  belongs_to :user
  belongs_to :badge

  validates :user_id, uniqueness: { scope: :badge_id }
  #同じユーザーが同じバッジを複数回取得できないようにする
end
