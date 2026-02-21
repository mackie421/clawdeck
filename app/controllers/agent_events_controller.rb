class AgentEventsController < ApplicationController
  def show
    @dashboard_page = true
    @events = current_user.agent_events

    # Live Feed: all events, newest first
    @feed_events = @events.recent.limit(50)

    # Session History: group by session_id
    @sessions = @events
      .where.not(session_id: nil)
      .select("session_id, MIN(created_at) as started_at, MAX(created_at) as ended_at, COUNT(*) as event_count")
      .group(:session_id)
      .order("ended_at DESC")
      .limit(20)

    # Error Log: only errors
    @error_events = @events.errors_only.recent.limit(50)

    # Error count for badge
    @error_count = @events.errors_only.count
  end
end
