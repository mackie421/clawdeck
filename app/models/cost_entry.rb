class CostEntry < ApplicationRecord
  belongs_to :user

  MODELS = %w[kimi-k2.5 qwen-3.5-397b minimax-m2.5].freeze
  PROVIDERS = %w[kimi-coding nvidia-qwen openrouter].freeze
  AGENTS = %w[main digest larry].freeze

  validates :model_name, presence: true, inclusion: { in: MODELS }
  validates :provider, presence: true, inclusion: { in: PROVIDERS }
  validates :agent_id, presence: true, inclusion: { in: AGENTS }
  validates :input_tokens, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :output_tokens, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :cost_usd, presence: true, numericality: { greater_than_or_equal_to: 0 }

  scope :recent, -> { order(created_at: :desc) }
  scope :by_model, ->(model) { where(model_name: model) }
  scope :by_provider, ->(provider) { where(provider: provider) }
  scope :by_agent, ->(agent) { where(agent_id: agent) }
  scope :today, -> { where("created_at >= ?", Time.current.beginning_of_day) }
  scope :this_week, -> { where("created_at >= ?", Time.current.beginning_of_week) }
  scope :this_month, -> { where("created_at >= ?", Time.current.beginning_of_month) }
  scope :in_range, ->(from, to) { where(created_at: from..to) }
end
