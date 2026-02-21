class CreateContents < ActiveRecord::Migration[8.1]
  def change
    create_table :contents do |t|
      t.references :user, null: false, foreign_key: true
      t.references :board, null: true, foreign_key: true
      t.string :title, null: false
      t.text :body
      t.integer :platform, null: false, default: 0
      t.integer :content_type, null: false, default: 0
      t.integer :status, null: false, default: 0
      t.datetime :scheduled_at
      t.datetime :published_at
      t.string :tags, default: [], array: true
      t.integer :source, null: false, default: 0
      t.jsonb :metadata, default: {}

      t.timestamps
    end

    add_index :contents, [:user_id, :status]
    add_index :contents, [:user_id, :platform]
    add_index :contents, [:user_id, :scheduled_at]
    add_index :contents, :created_at
  end
end
