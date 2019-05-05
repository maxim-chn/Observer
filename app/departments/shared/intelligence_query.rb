# frozen_string_literal: true

module Departments
  module Shared
    ##
    # Unites the arguments for the {Departments::Intelligence::Api}.
    # The united arguments are the intelligence query that specifies what type of
    # the data we are interested in.
    class IntelligenceQuery
      attr_reader :friendly_resource_ip, :collect_format

      def initialize(friendly_resource_ip, collect_format)
        @friendly_resource_ip = friendly_resource_ip
        @collect_format = collect_format
      end

      # Textual representation of an object.
      # @return [String]
      def inspect
        result = {}
        result[:friendly_resource_ip] = @friendly_resource_ip
        result[:collect_format] = @collect_format
        JSON.generate(result)
      end
    end
  end
end
