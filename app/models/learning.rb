class Learning < ApplicationRecord
  belongs_to :user
  belongs_to :source_correction, class_name: "Learning", optional: true
  has_many :derived_rules, class_name: "Learning", foreign_key: :source_correction_id, dependent: :nullify

  enum :learning_type, {
    correction: 0,
    rule: 1,
    compaction: 2,
    improvement_proposal: 3
  }, prefix: true

  enum :category, {
    tone: 0,
    accuracy: 1,
    tool_use: 2,
    formatting: 3,
    boundaries: 4,
    other: 5
  }, prefix: true

  enum :status, {
    active: 0,
    proposed: 1,
    approved: 2,
    rejected: 3,
    superseded: 4
  }

  enum :severity, {
    minor: 0,
    moderate: 1,
    critical: 2
  }, prefix: true

  validates :title, presence: true
  validates :learning_type, inclusion: { in: learning_types.keys }
  validates :category, inclusion: { in: categories.keys }
  validates :status, inclusion: { in: statuses.keys }
  validates :severity, inclusion: { in: severities.keys }

  scope :corrections, -> { where(learning_type: :correction) }
  scope :rules, -> { where(learning_type: :rule) }
  scope :compactions, -> { where(learning_type: :compaction) }
  scope :improvement_proposals, -> { where(learning_type: :improvement_proposal) }
  scope :repeating, -> { where("repeat_count > 0").order(repeat_count: :desc) }
  scope :recent, -> { order(created_at: :desc) }

  # Similarity detection: find existing corrections in the same category
  # with keyword overlap in title/body
  def self.find_similar_correction(user:, category:, title:, body: nil)
    candidates = user.learnings.corrections.active.where(category: category)
    return nil if candidates.empty?

    # Extract keywords (3+ char words, downcased, unique)
    source_text = [title, body].compact.join(" ")
    keywords = source_text.downcase.scan(/\b[a-z]{3,}\b/).uniq

    best_match = nil
    best_overlap = 0

    candidates.find_each do |candidate|
      candidate_text = [candidate.title, candidate.body].compact.join(" ")
      candidate_keywords = candidate_text.downcase.scan(/\b[a-z]{3,}\b/).uniq
      overlap = (keywords & candidate_keywords).size

      if overlap > best_overlap && overlap >= 2
        best_match = candidate
        best_overlap = overlap
      end
    end

    best_match
  end

  # Increment repeat count on an existing learning
  def record_repeat!
    increment!(:repeat_count)
    update_column(:last_repeated_at, Time.current)
  end
end
