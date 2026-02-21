class Metric < ApplicationRecord
  belongs_to :user

  CATEGORIES = %w[social content business custom].freeze
  SOURCES = %w[larry_analytics manual api].freeze
  PLATFORMS = %w[instagram tiktok twitter linkedin youtube email_newsletter general].freeze

  validates :category, presence: true, inclusion: { in: CATEGORIES }
  validates :name, presence: true
  validates :value, presence: true
  validates :source, presence: true, inclusion: { in: SOURCES }
  validates :platform, inclusion: { in: PLATFORMS }, allow_nil: true

  scope :recent, -> { order(created_at: :desc) }
  scope :by_category, ->(cat) { where(category: cat) }
  scope :by_platform, ->(plat) { where(platform: plat) }
  scope :by_name, ->(name) { where(name: name) }
  scope :in_period, ->(from, to) { where("period_start >= ? AND period_end <= ?", from, to) }
end
