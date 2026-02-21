class ContentsController < ApplicationController
  def index
    @dashboard_page = true
    @contents = current_user.contents

    # Drafts: draft, review, approved statuses
    @drafts = @contents.drafts.recent

    # Ideas: idea status
    @ideas = @contents.ideas.recent

    # Calendar: scheduled + published, scoped to current week
    @week_start = (params[:week_start] ? Date.parse(params[:week_start]) : Date.current).beginning_of_week
    @week_end = @week_start.end_of_week
    @calendar_contents = @contents.scheduled_or_published
      .where("scheduled_at BETWEEN ? AND ? OR published_at BETWEEN ? AND ?",
        @week_start.beginning_of_day, @week_end.end_of_day,
        @week_start.beginning_of_day, @week_end.end_of_day)
      .order(:scheduled_at, :published_at)
  end

  def create
    @content = current_user.contents.new(content_params)

    if @content.save
      redirect_to contents_path, notice: "Content created."
    else
      redirect_to contents_path, alert: @content.errors.full_messages.join(", ")
    end
  end

  def update
    @content = current_user.contents.find(params[:id])

    if @content.update(content_params)
      redirect_to contents_path, notice: "Content updated."
    else
      redirect_to contents_path, alert: @content.errors.full_messages.join(", ")
    end
  end

  private

  def content_params
    params.require(:content).permit(:title, :body, :platform, :content_type, :status,
      :scheduled_at, :published_at, :source, :board_id, tags: [])
  end
end
