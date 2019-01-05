class FriendlyResource < ApplicationRecord
  has_many :dos_icmp_interpretation_data, class_name: 'Dos::Icmp::DosIcmpInterpretation'
  def latestCyberReports()
    cyberReports = []
    cyberReports << dos_interpretation_data_icmp.last()
    return cyberReports
  end
  def getLatestDosCyberReport(cyberReportType)
    result = nil
    case cyberReportType
    when Dos::DosReport::ICMP_DOS_CYBER_REPORT
      result = dos_icmp_interpretation_data.last()
    end
    return result
  end
  def inspect()
    result = {}
    result['name']      = name
    result['ipAddress'] = ip_address
    return JSON.generate(result)
  end
end # FriendlyResource
