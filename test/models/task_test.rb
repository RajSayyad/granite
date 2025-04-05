# frozen_string_literal: true

require "test_helper"

class TaskTest < ActiveSupport::TestCase
  def setup
    @user = create(:user)
    @task = create(:task, assigned_user: @user, task_owner: @user)
  end

  def test_timestamps_on_create_and_update
    task = Task.new(title: "Sample", assigned_user: @user, task_owner: @user)
    assert_nil task.created_at
    task.save!
    assert_equal task.created_at.to_i, task.updated_at.to_i

    task.update!(title: "Updated")
    assert task.updated_at > task.created_at
  end

  def test_task_should_be_invalid_without_assigned_user
    @task.assigned_user = nil
    assert_not @task.valid?
    assert_includes @task.errors.full_messages, "Assigned user must exist"
  end

  def test_task_title_length_validation
    @task.title = "a" * (Task::MAX_TITLE_LENGTH + 1)
    assert_not @task.valid?
  end

  def test_task_requires_title
    @task.title = ""
    assert_not @task.valid?
  end

  def test_valid_title_formats
    %w[title title_1 title! -title- _title_ /title 1].each do |title|
      @task.title = title
      assert @task.valid?
    end
  end

  def test_invalid_title_formats
    %w[/ *** __ ~ ...].each do |title|
      @task.title = title
      assert @task.invalid?
    end
  end

  def test_slug_should_be_parameterized_title
    task = create(:task, title: "My Cool Task", assigned_user: @user, task_owner: @user)
    assert_equal "my-cool-task", task.slug
  end

  def test_incremental_slugs
    3.times { create(:task, title: "Duplicate", assigned_user: @user, task_owner: @user) }
    slugs = Task.where("slug LIKE ?", "duplicate%").pluck(:slug)
    assert_equal slugs.uniq, slugs
  end

  def test_task_deletion_on_user_deletion
    owner = create(:user)
    create(:task, assigned_user: @user, task_owner: owner)
    assert_difference "Task.count", -1 do
      owner.destroy
    end
  end

  def test_task_reassigns_to_owner_if_assignee_deleted
    owner = create(:user)
    task = create(:task, assigned_user: @user, task_owner: owner)
    @user.destroy
    assert_equal owner.id, task.reload.assigned_user_id
  end
end
