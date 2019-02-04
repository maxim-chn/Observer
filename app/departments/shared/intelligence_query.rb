# frozen_string_literal: true

module Departments
  module Shared
    ##
    # Represents arguments for Departments::Intelligence::Api.
    class IntelligenceQuery
      attr_reader :friendly_resource_ip, :collect_format

      def initialize(friendly_resource_ip, collect_format)
        @friendly_resource_ip = friendly_resource_ip
        @collect_format = collect_format
      end

      # [return] String.
      #          Textual representation of an object.
      def inspect
        result = {}
        result[:friendly_resource_ip] = @friendly_resource_ip
        result[:collect_format] = @collect_format
        JSON.generate(result)
      end
    end
  end
end
