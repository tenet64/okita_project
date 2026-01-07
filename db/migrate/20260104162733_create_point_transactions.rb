class CreatePointTransactions < ActiveRecord::Migration[7.0]
  def change
    create_table :point_transactions do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :points, null: false, default: 0
      t.integer :reason, null: false
      t.references :source, polymorphic: true, null: false
      t.date :target_date, null: false

      t.timestamps
    end

    # 二重付与防止（ユーザー × 理由 × 付与元 × 日付で一意）
    add_index :point_transactions,
              [ :user_id, :reason, :source_type, :source_id, :target_date ],
              unique: true,
              name: "idx_point_tx_unique_grant"
  end
end
