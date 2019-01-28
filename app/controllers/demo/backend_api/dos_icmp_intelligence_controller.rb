# frozen_string_literal: true

module Demo
  ##
  # This class consumes [ArchiveApi].
  class CyberReportsController < ApplicationController
    # Renders a view template with a set of [CyberReport],
    # related to a particular [FriendlyResource].
    # +params+ - a [Hash] object that comes from GET request.
    def index
      friendly_resource_id = params[:friendly_resource_id]
      page = params[:page] || 1
      page_size = params[:page_size] || 10
      archive_api = Departments::Demo::Archive::Api.instance
      @cyber_reports = archive_api.getAllCyberReports(friendly_resource_id, page, page_size)
      @friendly_resource = archive_api.getFriendlyResourceById(friendly_resource_id)
    end

    # Renders a view template with a particular [CyberReport].
    # +params+ - a [Hash] object that comes from GET request.
    def show
      cyber_report_type = params[:type]
      cyber_report_id = params[:id]
      archive_api = Departments::Demo::Archive::Api.instance
      @cyber_report = archive_api.getCyberReportByIdAndType(cyber_report_id, cyber_report_type)
      @cyber_report_details = JSON.parse(@cyber_report.inspect)
      @friendly_resource = @cyber_report.friendly_resource
    end
  end
end
