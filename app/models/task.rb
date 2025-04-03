# frozen_string_literal: true

class Task < ApplicationRecord
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

  private

    def self.of_status(progress)
      if progress == :pending
        pending.in_order_of(:status, %w(starred unstarred)).order("updated_at DESC")
      else
        completed.in_order_of(:status, %w(starred unstarred)).order("updated_at DESC")
      end
    end

    def set_slug
      base_slug = title.parameterize
      existing_slugs = Task.where("slug LIKE ?", "#{base_slug}-%").pluck(:slug)

      # If exact slug already exists, apply incrementing logic
      if Task.exists?(slug: base_slug)
        slug_numbers = existing_slugs.map { |slug| slug[/\d+$/]&.to_i }.compact
        next_slug_number = slug_numbers.empty? ? 2 : slug_numbers.max + 1
        self.slug = "#{base_slug}-#{next_slug_number}"
      else
        self.slug = base_slug
      end
    end

    def slug_not_changed
      if will_save_change_to_slug? && self.persisted?
        errors.add(:slug, "is immutable!")
      end
    end
end
