class AgentEvent < ApplicationRecord
  belongs_to :user

  enum :event_type, {
    task_claimed: 0,
    task_completed: 1,
    tool_call: 2,
    message_sent: 3,
    error: 4,
    session_start: 5,
    session_end: 6,
    cron_run: 7
  }, prefix: true

  enum :severity, {
    info: 0,
    warning: 1,
    error: 2
  }, prefix: true

  validates :event_type, inclusion: { in: event_types.keys }
  validates :severity, inclusion: { in: severities.keys }

  scope :recent, -> { order(created_at: :desc) }
  scope :errors_only, -> { where(severity: :error) }
  scope :for_session, ->(sid) { where(session_id: sid) }

  # Broadcast to activity stream after creation
  after_create_commit :broadcast_to_activity_feed

  private

  def broadcast_to_activity_feed
    Turbo::StreamsChannel.broadcast_prepend_to(
      "activity_feed_#{user_id}",
      target: "live-feed",
      partial: "agent_events/event_item",
      locals: { event: self }
    )
  end
end
