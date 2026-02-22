class AddAssigneeToTasks < ActiveRecord::Migration[8.1]
  def up
    add_column :tasks, :assignee, :string
    add_index :tasks, :assignee

    # Backfill from existing assigned_to_agent boolean
    execute "UPDATE tasks SET assignee = 'agent' WHERE assigned_to_agent = true"
  end

  def down
    remove_column :tasks, :assignee
  end
end
