class ResearchEntriesController < ApplicationController
  def index
    @dashboard_page = true
    @entries = current_user.research_entries

    # Latest entries
    @latest = @entries.recent.limit(20)

    # By topic (grouped by tags)
    @by_topic = @entries.where("array_length(tags, 1) > 0")
      .recent.limit(50)

    # Trends
    @trends = @entries.trends.recent.limit(20)

    # Deep dives
    @deep_dives = @entries.deep_dives.recent.limit(20)
  end
end
