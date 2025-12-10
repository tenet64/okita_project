class CreateChallenges < ActiveRecord::Migration[7.2]
  def change
    create_table :challenges do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title
      t.integer :mode
      t.integer :status
      t.time :target_time
      t.date :target_date
      t.integer :capacity

      t.timestamps
    end
  end
end
