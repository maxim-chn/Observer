class FriendlyResource < ApplicationRecord
  has_many :dos_interpretation_data

  def latestCyberReports()
    cyberReports = []
    cyberReports << dos_interpretation_data.last()
    return cyberReports
  end
end # FriendlyResource
