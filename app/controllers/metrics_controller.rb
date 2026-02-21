class MetricsController < ApplicationController
  def index
    @dashboard_page = true
    @metrics = current_user.metrics

    # Overview cards: latest values for key metrics
    @latest_by_name = @metrics.recent
      .select("DISTINCT ON (name) *")
      .order(:name, created_at: :desc)

    # Category breakdown
    @social_metrics = @metrics.by_category("social").recent.limit(20)
    @content_metrics = @metrics.by_category("content").recent.limit(20)
    @business_metrics = @metrics.by_category("business").recent.limit(20)

    # Chart data: last 30 days of metrics grouped by name
    @chart_start = 30.days.ago.beginning_of_day
    @chart_metrics = @metrics.where("created_at >= ?", @chart_start)
      .order(:name, :created_at)

    # Reports: aggregated summaries
    @total_metrics = @metrics.count
    @platforms_tracked = @metrics.where.not(platform: nil).distinct.pluck(:platform)
    @categories_tracked = @metrics.distinct.pluck(:category)
  end
end
