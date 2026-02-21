class CreateLearnings < ActiveRecord::Migration[8.1]
  def change
    create_table :learnings do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :learning_type, null: false, default: 0
      t.integer :category, null: false, default: 5
      t.string :title, null: false
      t.text :body
      t.integer :status, null: false, default: 0
      t.integer :severity, null: false, default: 0
      t.bigint :source_correction_id
      t.integer :repeat_count, null: false, default: 0
      t.datetime :last_repeated_at
      t.jsonb :metadata, default: {}

      t.timestamps
    end

    add_index :learnings, [:user_id, :learning_type]
    add_index :learnings, [:user_id, :status]
    add_index :learnings, [:user_id, :category]
    add_index :learnings, :repeat_count
    add_index :learnings, :source_correction_id
    add_foreign_key :learnings, :learnings, column: :source_correction_id, name: "fk_learnings_source_correction"
  end
end
