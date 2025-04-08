# frozen_string_literal: true

class Tasks::ReportsController < ApplicationController
  def create
    ReportsJob.perform_async(current_user.id)
    render_notice(t("in_progress", action: "Report generation"))
  end

  def download
    unless @current_user.report.attached?
      render_error(t("not_found", entity: "report"), :not_found) and return
    end

    send_data @current_user.report.download, filename: pdf_file_name, content_type: "application/pdf"
  end

  private

    def report_path
      @_report_path ||= Rails.root.join("tmp/#{pdf_file_name}")
    end

    def pdf_file_name
      "granite_task_report.pdf"
    end
end
