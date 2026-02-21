class ResearchEntry < ApplicationRecord
  belongs_to :user

  RESEARCH_TYPES = %w[trend deep_dive competitor market general].freeze
  SOURCES = %w[larry_research last_30_days tavily manual].freeze

  validates :title, presence: true
  validates :research_type, presence: true, inclusion: { in: RESEARCH_TYPES }
  validates :source, presence: true, inclusion: { in: SOURCES }
  validates :relevance_score, numericality: { greater_than_or_equal_to: 0.0, less_than_or_equal_to: 1.0 }, allow_nil: true

  scope :recent, -> { order(created_at: :desc) }
  scope :by_type, ->(type) { where(research_type: type) }
  scope :by_source, ->(src) { where(source: src) }
  scope :trends, -> { where(research_type: "trend") }
  scope :deep_dives, -> { where(research_type: "deep_dive") }
  scope :high_relevance, -> { where("relevance_score >= ?", 0.7).order(relevance_score: :desc) }

  def rendered_body
    body.presence || ""
  end
end
