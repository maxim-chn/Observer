class FriendlyResource < ApplicationRecord
  has_many :dos_icmp_interpretation_data, class_name: 'Dos::Icmp::DosIcmpInterpretation'
  def latestCyberReports()
    cyberReports = []
    cyberReports << dos_interpretation_data_icmp.last()
    return cyberReports
  end
  def inspect()
    result = {}
    result[:name]      = name
    result[:ipAddress] = ip_address
    return JSON.generate(result)
  end
end # FriendlyResource
