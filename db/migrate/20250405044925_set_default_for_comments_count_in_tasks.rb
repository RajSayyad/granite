# frozen_string_literal: true

class SetDefaultForCommentsCountInTasks < ActiveRecord::Migration[7.1]
  def change
    change_column_default :tasks, :comments_count, from: nil, to: 0
    change_column_null :tasks, :comments_count, false, 0
  end
end
