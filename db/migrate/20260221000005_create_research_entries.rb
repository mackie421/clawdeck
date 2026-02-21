class CreateResearchEntries < ActiveRecord::Migration[8.1]
  def change
    create_table :research_entries do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.text :body
      t.string :research_type, null: false, default: "general"
      t.string :source, null: false, default: "manual"
      t.string :tags, default: [], array: true
      t.decimal :relevance_score, precision: 3, scale: 2
      t.jsonb :metadata, default: {}

      t.timestamps
    end

    add_index :research_entries, [:user_id, :created_at]
    add_index :research_entries, [:user_id, :research_type]
    add_index :research_entries, [:user_id, :source]
  end
end
