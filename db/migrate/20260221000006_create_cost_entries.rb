class CreateCostEntries < ActiveRecord::Migration[8.1]
  def change
    create_table :cost_entries do |t|
      t.references :user, null: false, foreign_key: true
      t.string :model_name, null: false
      t.string :provider, null: false
      t.string :agent_id, null: false, default: "main"
      t.integer :input_tokens, null: false, default: 0
      t.integer :output_tokens, null: false, default: 0
      t.decimal :cost_usd, null: false, precision: 10, scale: 6
      t.string :session_id
      t.jsonb :metadata, default: {}

      t.timestamps
    end

    add_index :cost_entries, [:user_id, :created_at]
    add_index :cost_entries, [:user_id, :model_name]
    add_index :cost_entries, [:user_id, :provider]
    add_index :cost_entries, [:user_id, :agent_id]
  end
end
