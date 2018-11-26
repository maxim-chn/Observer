class Demo::CyberReportsController < ApplicationController
  def index
    friendlyResourceId = params[:friendly_resource_id] 
    @friendlyResource = FriendlyResource.find(friendlyResourceId)
    @cyberReports = @friendlyResource.latestCyberReports()
    # render demo/cyber_reports/index.html.erb
  end

  def show
    cyberReportType     = params[:type]
    cyberReportId       = params[:id]
    @cyberReport        = CyberReport.findSpecificReport(cyberReportType, cyberReportId)
    @cyberReportDetails = CyberReport.getDetailsForSpecificReport(@cyberReport)
    @friendlyResource   = @cyberReport.friendly_resource()
    # render demo/cyber_reports/show.html.erb
  end
end # Demo::CyberReportsController
