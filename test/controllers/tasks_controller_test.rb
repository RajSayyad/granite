# frozen_string_literal: true

require "test_helper"

class TasksControllerTest < ActionDispatch::IntegrationTest
  def setup
    @creator = create(:user)
    @assignee = create(:user)
    @task = create(:task, assigned_user: @assignee, task_owner: @creator)
    @creator_headers = headers(@creator)
    @assignee_headers = headers(@assignee)
  end

  def test_should_list_all_tasks_for_valid_user
    get tasks_path, headers: @creator_headers
    assert_response :success

    tasks = response.parsed_body["tasks"]
    assert_equal Task.where(progress: "pending").pluck(:id).sort, tasks["pending"].pluck("id").sort
    assert_equal Task.where(progress: "completed").pluck(:id).sort, tasks["completed"].pluck("id").sort
  end

  def test_should_create_valid_task
    post tasks_path,
      params: { task: { title: "Learn Ruby", task_owner_id: @creator.id, assigned_user_id: @assignee.id } },
      headers: @creator_headers

    assert_response :success
    assert_equal I18n.t("successfully_created", entity: "Task"), response.parsed_body["notice"]
  end

  def test_should_not_create_task_without_title
    post tasks_path,
      params: { task: { title: "", task_owner_id: @creator.id, assigned_user_id: @assignee.id } },
      headers: @creator_headers

    assert_response :unprocessable_entity
    assert_equal "Title can't be blank, Title is invalid", response.parsed_body["error"]
  end

  def test_creator_can_update_any_task_fields
    new_title = "#{@task.title}-(updated)"
    put task_path(@task.slug),
      params: { task: { title: new_title, assigned_user_id: @assignee.id } },
      headers: @creator_headers

    assert_response :success
    @task.reload
    assert_equal new_title, @task.title
  end

  def test_should_destroy_task
    assert_difference "Task.count", -1 do
      delete task_path(@task.slug), headers: @creator_headers
    end
    assert_response :ok
  end

  def test_assignee_should_not_destroy_task
    delete task_path(@task.slug), headers: @assignee_headers
    assert_response :forbidden
    assert_equal I18n.t("authorization.denied"), response.parsed_body["error"]
  end

  def test_assignee_should_not_update_restricted_task_fields
    assert_no_changes -> { @task.reload.title } do
      put task_path(@task.slug),
        params: { task: { title: "updated", assigned_user_id: @assignee.id } },
        headers: @assignee_headers

      assert_response :forbidden
    end
  end

  def test_both_creator_and_assignee_can_change_status_and_progress
    %i[@creator_headers @assignee_headers].each do |header|
      put task_path(@task.slug),
        params: { task: { status: "starred", progress: "completed" } },
        headers: instance_variable_get(header)

      assert_response :success
      @task.reload
      assert @task.starred?
      assert @task.completed?
    end
  end

  def test_not_found_error_for_invalid_task_slug
    get task_path("invalid-slug"), headers: @creator_headers
    assert_response :not_found
    assert_equal I18n.t("not_found", entity: "Task"), response.parsed_body["error"]
  end
end
