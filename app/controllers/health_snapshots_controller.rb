class HealthSnapshotsController < ApplicationController
  def index
    @dashboard_page = true
    @snapshots = current_user.health_snapshots

    # Latest snapshot
    @latest = @snapshots.recent.first

    # Recent errors from agent_events (severity=error)
    @recent_errors = current_user.agent_events
      .where(severity: "error")
      .order(created_at: :desc)
      .limit(10)

    # Historical snapshots for resource trend (last 24 hours)
    @history_24h = @snapshots.where("created_at >= ?", 24.hours.ago)
      .order(created_at: :asc)

    # Uptime calculation
    @uptime_display = if @latest&.uptime_seconds.present?
      format_uptime(@latest.uptime_seconds)
    end

    # Total snapshots
    @total_snapshots = @snapshots.count
  end

  private

  def format_uptime(seconds)
    days = seconds / 86400
    hours = (seconds % 86400) / 3600
    minutes = (seconds % 3600) / 60

    parts = []
    parts << "#{days}d" if days > 0
    parts << "#{hours}h" if hours > 0
    parts << "#{minutes}m" if minutes > 0
    parts.empty? ? "0m" : parts.join(" ")
  end
end
