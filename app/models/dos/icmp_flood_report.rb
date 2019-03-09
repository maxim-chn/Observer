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

    # A hook to ensure initialization of a new object with legal values.
    after_initialize :init_default_values

    # A method that is called after initialization of a new object.
    # It takes care of attributes that user has forgotten to pass value for them.
    def init_default_values
      validate_mandatory_values
      self.aberrant_behavior = false unless aberrant_behavior
      self.actual_value = 0.0 unless actual_value
    end

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

    private

    # Throws {Exception} if following values are illegal:
    # - +self.seasonal_index+
    # * +self.report_type+
    def validate_mandatory_values
      validate_seasonal_index
      validate_report_type
    end

    def validate_seasonal_index
      if seasonal_index
        return if seasonal_index.between?(
          DosReport::FIRST_SEASONAL_INDEX,
          DosReport::LAST_SEASONAL_INDEX
        )

        throw Exception.new("#{self.class.name} - #{__method__} - seasonal_index must \
          be in range [#{DosReport::FIRST_SEASONAL_INDEX},#{DosReport::LAST_SEASONAL_INDEX}].")
      end
      throw Exception.new("#{self.class.name} - #{__method__} - missing seasonal_index value.\
        It is mandatory for new object.")
    end

    def validate_report_type
      return if report_type

      throw Exception.new("#{self.class.name} - #{__method__} - report_type must have a value.")
    end
  end
end
