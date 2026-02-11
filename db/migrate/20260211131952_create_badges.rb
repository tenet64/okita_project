class CreateBadges < ActiveRecord::Migration[7.2]
  def change
    create_table :badges do |t|
      t.string :name, null: false
      t.text :description, null: false
      t.string :image_path, null: false
      t.string :condition_key, null: false

      t.timestamps
    end
    add_index :badges, :condition_key, unique: true
  end
end
