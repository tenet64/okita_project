class CreateWakeUpLogs < ActiveRecord::Migration[7.2]
  def change
    create_table :wake_up_logs do |t|
      t.references :user, null: false, foreign_key: true
      t.references :challenge, null: false, foreign_key: true
      t.date :target_date
      t.datetime :pressed_at
      t.integer :status

      t.timestamps
    end
  end
end
