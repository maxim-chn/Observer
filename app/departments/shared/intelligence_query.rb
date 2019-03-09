# frozen_string_literal: true

module Departments
  module Shared
    ##
    # Unites arguments for [Departments::Intelligence::Api].
    # United arguments are the intelligence query that specifies what type of
    # of data we are interested in collecting and what not.
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
