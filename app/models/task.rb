# frozen_string_literal: true

class Task < ApplicationRecord
  scope :accessible_to, ->(user_id) { where("task_owner_id = ? OR assigned_user_id = ?", user_id, user_id) }
  MAX_TITLE_LENGTH = 125
  VALID_TITLE_REGEX = /\A.*[a-zA-Z0-9].*\z/i
  RESTRICTED_ATTRIBUTES = %i[title task_owner_id assigned_user_id]

  enum :progress, { pending: "pending", completed: "completed" }, default: :pending
  enum :status, { unstarred: "unstarred", starred: "starred" }, default: :unstarred

  has_many :comments, dependent: :destroy
  belongs_to :assigned_user, foreign_key: "assigned_user_id", class_name: "User"
  belongs_to :task_owner, foreign_key: "task_owner_id", class_name: "User"

  validates :title,
    presence: true,
    length: { maximum: MAX_TITLE_LENGTH },
    format: { with: VALID_TITLE_REGEX }
  validates :slug, uniqueness: true
  validate :slug_not_changed

  before_create :set_slug
  after_create :log_task_details

  def self.of_status(progress)
    scope = progress == :pending ? pending : completed
    scope.in_order_of(:status, %w[starred unstarred]).order("updated_at DESC")
  end

  private

    def log_task_details
      TaskLoggerJob.perform_async(id)
    end

    def set_slug
      base_slug = title.parameterize
      existing_slugs = Task.where("slug LIKE ?", "#{base_slug}-%").pluck(:slug)

      if Task.exists?(slug: base_slug)
        suffixes = existing_slugs.map { |s| s[/\d+$/]&.to_i }.compact
        next_suffix = suffixes.empty? ? 2 : suffixes.max + 1
        self.slug = "#{base_slug}-#{next_suffix}"
      else
        self.slug = base_slug
      end
    end

    def slug_not_changed
      if will_save_change_to_slug? && persisted?
        errors.add(:slug, I18n.t("task.slug.immutable", default: "is immutable!"))
      end
    end
end
