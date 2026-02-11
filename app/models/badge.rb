class Badge < ApplicationRecord
    has_many :user_badges, dependent: :destroy
    has_many :users, through: :user_badges
    
    validates :name, presence: true
    validates :description, presence: true
    validates :image_path, presence: true
    validates :condition_key, presence: true, uniqueness: true
end
