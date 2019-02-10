# frozen_string_literal: true

##
# Action View Controller for {CyberReport}.
# Consumes {Departments::Archive::Api}.
class CyberReportsController < ApplicationController
  def index
    friendly_resource_id = params[:friendly_resource_id]
    archive_api = Departments::Archive::Api.instance
    @friendly_resource = archive_api.friendly_resource_by_id(friendly_resource_id)
    @cyber_reports = []
  end

  def show
    cyber_report_type = params[:type]
    cyber_report_id = params[:id]
    archive_api = Departments::Archive::Api.instance
    @cyber_report = archive_api.cyber_report_by_id_and_type(cyber_report_id, cyber_report_type)
    @cyber_report_details = JSON.parse(@cyber_report.inspect)
    @friendly_resource = @cyber_report.friendly_resource
  end
end
