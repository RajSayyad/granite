# frozen_string_literal: true

class Comment < ApplicationRecord
  MAX_CONTENT_LENGTH = 511

  belongs_to :user # Each comment belongs to a single user
  belongs_to :task, counter_cache: true

  validates :content, presence: true, length: { maximum: MAX_CONTENT_LENGTH }
end
