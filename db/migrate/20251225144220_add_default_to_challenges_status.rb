class AddDefaultToChallengesStatus < ActiveRecord::Migration[7.2]
  def change
    change_column_default :challenges, :status, 0
  end
end
