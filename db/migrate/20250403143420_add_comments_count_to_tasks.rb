# frozen_string_literal: true

class AddCommentsCountToTasks < ActiveRecord::Migration[7.1]
  def change
    add_column :tasks, :comments_count, :integer
  end
end
