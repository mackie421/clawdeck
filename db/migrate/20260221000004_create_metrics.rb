class CreateMetrics < ActiveRecord::Migration[8.1]
  def change
    create_table :metrics do |t|
      t.references :user, null: false, foreign_key: true
      t.string :category, null: false
      t.string :name, null: false
      t.decimal :value, null: false
      t.string :platform
      t.datetime :period_start
      t.datetime :period_end
      t.string :source, null: false, default: "manual"
      t.jsonb :metadata, default: {}

      t.timestamps
    end

    add_index :metrics, [:user_id, :created_at]
    add_index :metrics, [:user_id, :category]
    add_index :metrics, [:user_id, :name]
    add_index :metrics, [:user_id, :platform]
  end
end
