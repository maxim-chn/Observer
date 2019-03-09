# frozen_string_literal: true

##
# A model that represents friendly resource.
class FriendlyResource < ApplicationRecord
  # Relation to models that extend [CyberReport].
  has_many :icmp_flood_report, class_name: 'Dos::IcmpFloodReport', dependent: :destroy

  # String representation of an object.
  # @return [String]
  def inspect
    result = {}
    result['name'] = name
    result['ip_address'] = ip_address
    JSON.generate(result)
  end
end
