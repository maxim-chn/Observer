# frozen_string_literal: true

##
# {Action View Controller}[https://guides.rubyonrails.org/action_controller_overview.html] for {CyberReport}.
# Consumes {Departments::Archive::Api}.
class CyberReportsController < ApplicationController
  # Renders a HTML document with a collection of available {CyberReport} types for a
  # particular {FriendlyResource}
  def index
    friendly_resource_id = params[:friendly_resource_id].to_i if params[:friendly_resource_id]
    archive_api = Departments::Archive::Api.instance
    @friendly_resource = archive_api.friendly_resource_by_id(friendly_resource_id)
    @cyber_report_types = archive_api.cyber_report_types
  end

  # Renders a HTML document with a collection of certain {CyberReport} type.
  # For example, reports of type {Dos::IcmpFloodReport} are a collection of graph points.
  def show_reports
    type = params[:type]
    id = params[:friendly_resource_id].to_i if params[:friendly_resource_id]
    page = params[:page] || '1'
    page_size = params[:page_size] || '20'
    archive_api = Departments::Archive::Api.instance
    think_tank_api = Departments::ThinkTank::Api.instance
    @friendly_resource = archive_api.friendly_resource_by_id(id)
    @cyber_report_type = params[:type]
    max_records = archive_api.cyber_reports_count(@friendly_resource.ip_address, type)
    case @cyber_report_type
    when Departments::Shared::AnalysisType::ICMP_DOS_CYBER_REPORT
      @dos_icmp_reports = think_tank_api.latest_cyber_reports_graph(
        @cyber_report_type,
        @friendly_resource.ip_address,
        page.to_i,
        page_size.to_i
      )
      @dos_icmp_reports = WillPaginate::Collection.create(page.to_i, page_size.to_i, max_records) do |pager|
        pager.replace(@dos_icmp_reports)
      end
    when Departments::Shared::AnalysisType::SQL_INJECTION_CYBER_REPORT
      @sql_injection_reports = archive_api.cyber_reports_by_friendly_resource_ip_and_type(
        @friendly_resource.ip_address,
        @cyber_report_type,
        page.to_i,
        page_size.to_i
      )
      @sql_injection_reports = WillPaginate::Collection.create(page.to_i, page_size.to_i, max_records) do |pager|
        pager.replace(@sql_injection_reports)
      end
    end
  end
end
