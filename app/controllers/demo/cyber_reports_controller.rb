class Demo::CyberReportsController < ApplicationController
  def index
    friendlyResourceId = params[:friendly_resource_id]
    page               = params[:page] ? params[:page] : 1
    pageSize           = params[:page_size] ? params[:page_size] : 10
    archiveApi         = Departments::Demo::Archive::Api.instance()
    @cyberReports      = archiveApi.getAllCyberReports(friendlyResourceId, page, pageSize)
    @friendlyResource  = archiveApi.getFriendlyResourceById(friendlyResourceId)
    # render demo/cyber_reports/index.html.erb
  end

  def show
    cyberReportType     = params[:type]
    cyberReportId       = params[:id]
    archiveApi          = Departments::Demo::Archive::Api.instance()
    @cyberReport        = archiveApi.getCyberReportByIdAndType(cyberReportId, cyberReportType)
    @cyberReportDetails = eval(@cyberReport.inspect())
    @friendlyResource   = @cyberReport.friendly_resource()
    # render demo/cyber_reports/show.html.erb
  end
end # Demo::CyberReportsController
