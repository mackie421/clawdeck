class CreateAgentEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :agent_events do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :event_type, null: false, default: 0
      t.string :agent_name
      t.string :agent_emoji
      t.text :summary
      t.jsonb :details, default: {}
      t.string :session_id
      t.integer :severity, null: false, default: 0

      t.timestamps
    end

    add_index :agent_events, [:user_id, :created_at]
    add_index :agent_events, [:user_id, :event_type]
    add_index :agent_events, [:user_id, :severity]
    add_index :agent_events, :session_id
    add_index :agent_events, :created_at
  end
end
