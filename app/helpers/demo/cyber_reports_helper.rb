module Demo::CyberReportsHelper
  def getCyberReportType(cyberReport)
    type = "None"
    type = cyberReport.type() unless cyberReport.nil?
    return type
  end

  def getCyberReportDate(cyberReport)
    date = DateTime.now()
    date = cyberReport.created_at() unless cyberReport.nil?
    return date
  end
end # Demo::CyberReportsHelper
