class CyberReport < ApplicationRecord
  self.abstract_class = true
  def self.findSpecificReport(type, id)
    cyberReport = nil
    case type
    when "DosInterpretationData"
      cyberReport = DosInterpretationData.find(id)
    end
    return cyberReport
  end
  def self.getDetailsForSpecificReport(cyberReport)
    details = {}
    type    = cyberReport.class().to_s()
    case type
    when "Demo::Dos::Icmp::InterpretationData"
      details = getDetailsFromInterpretationReport(cyberReport)
    end
    return details
  end
  private
  def getDetailsFromInterpretationReport(cyberReport)
    result = {}
    details["Baseline"]                             = cyberReport.baseline()
    details["Trend"]                                = cyberReport.trend()
    details["Seasonal trend"]                       = cyberReport.seasonal_trend()
    details["Weighted average absolute deviation"]  = cyberReport.weighted_average_absolute_deviation()
    details["Aberrant behavior"]                    = cyberReport.aberrant_behavior()
    details["Actual Value"]                         = cyberReport.actual_value()
    return result
  end
end # СyberReport