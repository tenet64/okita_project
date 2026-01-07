class AddUniqueIndexesForPoints < ActiveRecord::Migration[7.2]
  def change
    add_index :participations, [ :user_id, :challenge_id ], unique: true
    add_index :wake_up_logs, [ :user_id, :challenge_id, :target_date ], unique: true
  end
end
