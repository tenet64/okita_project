class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  validates :name, presence: true
  has_many :challenges, dependent: :destroy
  has_many :wake_up_logs, dependent: :destroy
  has_many :point_transactions, dependent: :destroy
  has_many :participations, dependent: :destroy
  has_many :user_badges, dependent: :destroy
  has_many :badges, through: :user_badges
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
end
