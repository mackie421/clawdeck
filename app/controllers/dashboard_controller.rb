class DashboardController < ApplicationController
  def show
    @dashboard_page = true
    @boards = current_user.boards.includes(:tasks)
    @all_tasks = current_user.tasks.includes(:board)

    # Agenda: today's tasks (due today or in progress), ordered by priority desc then due date
    @agenda_tasks = @all_tasks
      .where.not(status: :done)
      .where("due_date = ? OR status = ?", Date.current, Task.statuses[:in_progress])
      .reorder(priority: :desc, due_date: :asc)
      .limit(10)

    # Progress: completion stats
    @done_today = @all_tasks.where(status: :done, completed_at: Date.current.all_day).count
    @done_this_week = @all_tasks.where(status: :done, completed_at: Date.current.beginning_of_week..Date.current.end_of_day).count
    @total_open = @all_tasks.where.not(status: :done).count
    @completion_streak = calculate_streak

    # Priority Queue: top 5 high-priority tasks across all boards
    @priority_tasks = @all_tasks
      .where.not(status: :done)
      .where(priority: [ Task.priorities[:high], Task.priorities[:medium] ])
      .reorder(priority: :desc, created_at: :asc)
      .limit(5)

    # Overnight Digest: latest content entries (last 24 hours)
    @digest_contents = current_user.contents
      .where("created_at >= ?", 24.hours.ago)
      .order(created_at: :desc)
      .limit(5)

    # Agent Status: use agent_events if available, fall back to task_activities
    @agent_active = current_user.agent_last_active_at.present? && current_user.agent_last_active_at > 5.minutes.ago
    @last_agent_event = current_user.agent_events.recent.first
    @agent_in_session = @last_agent_event.present? &&
      @last_agent_event.event_type_session_start? &&
      !current_user.agent_events.where(session_id: @last_agent_event.session_id, event_type: :session_end).exists?

    # Fall back to task_activities if no agent_events exist
    @last_agent_activity = if @last_agent_event.nil?
      TaskActivity
        .joins(:task)
        .where(tasks: { user_id: current_user.id }, source: "api")
        .order(created_at: :desc)
        .first
    end
  end

  private

  def calculate_streak
    streak = 0
    date = Date.current

    loop do
      # For today, check if any tasks are done; for past days, check completed_at
      count = current_user.tasks.where(status: :done, completed_at: date.all_day).count
      break if count == 0 && date < Date.current
      streak += 1 if count > 0
      date -= 1.day
      break if count == 0 # break on first day with no completions
    end

    streak
  end
end
