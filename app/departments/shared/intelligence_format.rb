# frozen_string_literal: true

module Departments
  module Shared
    ##
    # Holds Enum objects for identifying intelligence type.
    module IntelligenceFormat
      DOS_ICMP = 'dos_icmp'

      # Collection of available intelligence types
      # @return [Array<String>]
      def self.dos_formats
        result = []
        result << DOS_ICMP
        result
      end
    end
  end
end
