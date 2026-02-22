class AddPhase7Indexes < ActiveRecord::Migration[8.1]
  def change
    # Contents: composite for user-scoped recent queries
    add_index :contents, [:user_id, :created_at], name: "index_contents_on_user_id_and_created_at"

    # Learnings: composite for filtered tab queries (type + status)
    add_index :learnings, [:user_id, :learning_type, :status], name: "index_learnings_on_user_type_status"

    # Agent Events: composite for filtered + sorted queries
    add_index :agent_events, [:user_id, :event_type, :created_at], name: "index_agent_events_on_user_type_created"

    # Research Entries: composite for type + sort queries
    add_index :research_entries, [:user_id, :research_type, :created_at], name: "index_research_entries_on_user_type_created"
  end
end
