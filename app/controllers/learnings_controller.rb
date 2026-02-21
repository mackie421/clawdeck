class LearningsController < ApplicationController
  def index
    @dashboard_page = true
    @learnings = current_user.learnings

    # Corrections Feed: active corrections, newest first
    @corrections = @learnings.corrections.active.recent

    # Failure Rules: approved rules, grouped by category
    @rules = @learnings.rules.approved.recent

    # Repeat Tracker: entries with repeat_count > 0, sorted by frequency
    @repeats = @learnings.corrections.repeating

    # Improvement Queue: proposed improvement_proposals
    @proposals = @learnings.improvement_proposals.proposed.recent

    # Compaction Log: compaction entries, newest first
    @compactions = @learnings.compactions.recent
  end

  def update
    @learning = current_user.learnings.find(params[:id])

    if @learning.update(learning_params)
      redirect_to learnings_path, notice: "Learning updated."
    else
      redirect_to learnings_path, alert: @learning.errors.full_messages.join(", ")
    end
  end

  # POST /learnings/:id/create_rule — pre-fill a rule from a correction
  def create_rule
    correction = current_user.learnings.corrections.find(params[:id])

    rule = current_user.learnings.create!(
      learning_type: :rule,
      category: correction.category,
      title: "Rule: #{correction.title}",
      body: correction.body,
      status: :proposed,
      severity: correction.severity,
      source_correction_id: correction.id
    )

    redirect_to learnings_path, notice: "Rule proposed from correction."
  end

  private

  def learning_params
    params.require(:learning).permit(:status, :body, :title, :severity)
  end
end
