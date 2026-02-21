class Content < ApplicationRecord
  belongs_to :user
  belongs_to :board, optional: true

  enum :platform, {
    x: 0,
    instagram: 1,
    linkedin: 2,
    threads: 3,
    youtube: 4,
    email_newsletter: 5,
    general: 6
  }, prefix: true

  enum :content_type, {
    post: 0,
    reel: 1,
    story: 2,
    carousel: 3,
    article: 4,
    idea: 5
  }, prefix: true

  enum :status, {
    idea: 0,
    draft: 1,
    review: 2,
    approved: 3,
    scheduled: 4,
    published: 5,
    archived: 6
  }

  enum :source, {
    manual: 0,
    larry_content: 1,
    agent: 2
  }, prefix: true

  validates :title, presence: true
  validates :platform, inclusion: { in: platforms.keys }
  validates :content_type, inclusion: { in: content_types.keys }
  validates :status, inclusion: { in: statuses.keys }
  validates :source, inclusion: { in: sources.keys }

  scope :drafts, -> { where(status: [:draft, :review, :approved]) }
  scope :ideas, -> { where(status: :idea) }
  scope :scheduled_or_published, -> { where(status: [:scheduled, :published]) }
  scope :recent, -> { order(created_at: :desc) }
end
