# frozen_string_literal: true

##
# Action View Controller for {CyberReport}.
# Consumes {Departments::Archive::Api}.
class CyberReportsController < ApplicationController
  def index
    friendly_resource_id = params[:friendly_resource_id]
    archive_api = Departments::Archive::Api.instance
    @friendly_resource = archive_api.friendly_resource_by_id(friendly_resource_id)
    @cyber_report_types = archive_api.cyber_report_types
  end

  def show_reports
    type = params[:type]
    id = params[:friendly_resource_id]
    page = params[:page] || 1
    page_size = params[:page_size] || 20
    page = page.to_i if page.class == String
    page_size = page_size.to_i if page_size.class == String
    archive_api = Departments::Archive::Api.instance
    think_tank_api = Departments::ThinkTank::Api.instance
    @friendly_resource = archive_api.friendly_resource_by_id(id)
    @cyber_reports_graph = think_tank_api.latest_cyber_reports_graph(type, @friendly_resource.ip_address, page, page_size)
    max_records = archive_api.cyber_records_count(@friendly_resource.ip_address, type)
    @cyber_reports_graph = WillPaginate::Collection.create(page, page_size, max_records) do |pager|
      pager.replace(@cyber_reports_graph)
    end
  end
end
