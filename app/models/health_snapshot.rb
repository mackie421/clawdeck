class HealthSnapshot < ApplicationRecord
  belongs_to :user

  SOURCES = %w[heartbeat manual agent].freeze
  GATEWAY_STATUSES = %w[up down degraded].freeze
  TELEGRAM_STATUSES = %w[connected disconnected].freeze

  validates :source, presence: true, inclusion: { in: SOURCES }
  validates :gateway_status, presence: true, inclusion: { in: GATEWAY_STATUSES }
  validates :telegram_status, presence: true, inclusion: { in: TELEGRAM_STATUSES }
  validates :disk_usage_pct, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, allow_nil: true
  validates :memory_usage_pct, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, allow_nil: true
  validates :cpu_load, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  scope :recent, -> { order(created_at: :desc) }
  scope :by_source, ->(source) { where(source: source) }
end
