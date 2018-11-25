class FriendlyResource < CyberReport
  has_many :dos_interpretation_data

  def cyber_reports()
    cyber_reports = []
    cyber_reports << dos_interpretation_data.last()
    return cyber_reports
  end
end # FriendlyResource
