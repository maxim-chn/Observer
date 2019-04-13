# frozen_string_literal: true

module Dos
  ##
  # A class for DoS interpretation data for ICMP protocol. It is used during ICMP flood attack.
  # "data" had to be removed from class name, due to restrictions on class name length.
  # We have additional "DosIcmp" in class name, because Rails translates
  # class name into table name and neglects namespacing before class name.
  class IcmpFloodReport < Dos::DosReport
    # Relation to {FriendlyResource} model.
    belongs_to :friendly_resource, class_name: 'FriendlyResource'

    # String representation of an object.
    # @return [String]
    def inspect
      result = {}
      result[:aberrant_behavior] = aberrant_behavior
      result[:actual_value] = actual_value
      result[:baseline] = baseline
      result[:confidence_band_upper_value] = confidence_band_upper_value
      result[:estimated_value] = estimated_value
      result[:linear_trend] = linear_trend
      result[:seasonal_index] = seasonal_index
      result[:seasonal_trend] = seasonal_trend
      result[:weighted_avg_abs_deviation] = weighted_avg_abs_deviation
      JSON.generate(result)
    end
  end
end
