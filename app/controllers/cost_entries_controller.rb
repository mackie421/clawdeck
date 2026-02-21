class CostEntriesController < ApplicationController
  def index
    @dashboard_page = true
    @entries = current_user.cost_entries

    # Spend card totals
    @today_total = @entries.today.sum(:cost_usd).to_f
    @week_total = @entries.this_week.sum(:cost_usd).to_f
    @month_total = @entries.this_month.sum(:cost_usd).to_f

    # Projected monthly (based on daily average this month)
    days_elapsed = [Time.current.day, 1].max
    daily_avg = @month_total / days_elapsed
    days_in_month = Time.current.end_of_month.day
    @projected_monthly = (daily_avg * days_in_month).round(4)

    # By model breakdown (this month)
    @by_model = @entries.this_month.group(:model_name).sum(:cost_usd).transform_values(&:to_f)

    # By agent breakdown (this month)
    @by_agent = @entries.this_month.group(:agent_id).sum(:cost_usd).transform_values(&:to_f)

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
