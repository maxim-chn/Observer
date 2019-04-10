# frozen_string_literal: true

##
# Holds helper methods for cyber reports view template.
module CyberReportsHelper
  # @return [String]
  def page_title_for_cyber_reports_view(page_details)
    "CyberReports | #{page_details}"
  end

  # @return [String]
  def cyber_report_name(cyber_report)
    if cyber_report
      type = cyberReport.class
      creation_date = cyber_report.created_at.strftime('%Y-%m-%dT%H:%M:%S')
      return "#{type} from #{creation_date}"
    end
    'None'
  end
end
