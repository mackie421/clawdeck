class CreateHealthSnapshots < ActiveRecord::Migration[8.1]
  def change
    create_table :health_snapshots do |t|
      t.references :user, null: false, foreign_key: true
      t.string :source, null: false, default: "heartbeat"
      t.string :gateway_status, null: false, default: "up"
      t.string :telegram_status, null: false, default: "connected"
      t.decimal :disk_usage_pct, precision: 5, scale: 2
      t.decimal :memory_usage_pct, precision: 5, scale: 2
      t.decimal :cpu_load, precision: 5, scale: 2
      t.jsonb :cron_results, default: {}
      t.integer :uptime_seconds, default: 0
      t.jsonb :error_entries, default: []

      t.timestamps
    end

    add_index :health_snapshots, [:user_id, :created_at]
    add_index :health_snapshots, [:user_id, :source]
  end
end
