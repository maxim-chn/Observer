# frozen_string_literal: true

##
# A model that represents friendly resource.
class FriendlyResource < ApplicationRecord
  # Relation to models that extend [CyberReport].
  has_many :icmp_flood_report, class_name: 'Dos::IcmpFloodReport', dependent: :destroy

  # @returns [Array] with objects of [CyberReport] subclasses.
  # Each object represents the latest [CyberReport] of a specific report.
  def latest_cyber_reports
    cyber_reports = []
    cyber_reports << icmp_flood_report.last
    cyber_reports
  end

  # Gives a [String] representaion of an object.
  def inspect
    result = {}
    result[:name] = name
    result[:ip_address] = ip_address
    JSON.generate(result)
  end
end
