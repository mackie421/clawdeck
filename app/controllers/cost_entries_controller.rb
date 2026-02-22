class CostEntriesController < ApplicationController
  def index
    @dashboard_page = true
    @entries = current_user.cost_entries

    # Spend card totals (cached 5 min — multiple SUM aggregations)
    spend = Rails.cache.fetch("costs/spend/#{current_user.id}/#{Date.current}", expires_in: 5.minutes) do
      today = @entries.today.sum(:cost_usd).to_f
      month = @entries.this_month.sum(:cost_usd).to_f
      days_elapsed = [Time.current.day, 1].max
      daily_avg = month / days_elapsed
      days_in_month = Time.current.end_of_month.day
      {
        today: today,
        week: @entries.this_week.sum(:cost_usd).to_f,
        month: month,
        projected: (daily_avg * days_in_month).round(4),
        by_model: @entries.this_month.group(:model_name).sum(:cost_usd).transform_values(&:to_f),
        by_agent: @entries.this_month.group(:agent_id).sum(:cost_usd).transform_values(&:to_f)
      }
    end
    @today_total = spend[:today]
    @week_total = spend[:week]
    @month_total = spend[:month]
    @projected_monthly = spend[:projected]
    @by_model = spend[:by_model]
    @by_agent = spend[:by_agent]

    # Daily history (last 30 days)
    @daily_history = @entries.where("created_at >= ?", 30.days.ago)
      .group("DATE(created_at)")
      .order("DATE(created_at) DESC")
      .pluck(Arel.sql("DATE(created_at)"), Arel.sql("SUM(cost_usd)"), Arel.sql("COUNT(*)"))
      .map { |date, total, count| { date: date, total: total.to_f, count: count } }

    # Recent entries for history detail
    @recent_entries = @entries.recent.limit(50)

    # Total entries count
    @total_entries = @entries.count
  end
end
