module Demo::CyberReportsHelper
  def getPageTitleForCyberReport(pageDetails)
    return "CyberReports | #{pageDetails}"
  end
  def getCyberReportType(cyberReport)
    type = "None"
    unless cyberReport.nil?
      type = cyberReport.class
    end
    return type
  end
  def getCyberReportName(cyberReport)
    name = "None"
    unless cyberReport.nil?
      cyberReportType         = cyberReport.class()
      cyberReportCreationDate = cyberReport.created_at().strftime("%Y-%m-%dT%H:%M:%S")
      name = "#{cyberReportType} from #{cyberReportCreationDate}"
    end
    return name
  end
end # Demo::CyberReportsHelper
