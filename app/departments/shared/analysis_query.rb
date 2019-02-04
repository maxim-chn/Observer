# frozen_string_literal: true

module Departments
  module Shared
    ##
    # Represents arguments for Departments::Analysis::Api.
    class AnalysisQuery
      attr_reader :friendly_resource_ip, :analysis_type

      def initialize(friendly_resource_ip, analysis_type)
        @friendly_resource_ip = friendly_resource_ip
        @analysis_type = analysis_type
      end

      # [return] String.
      #          Textual representaion of an object.
      def inspect
        result = {}
        result[:friendly_resource_ip] = @friendly_resource_ip
        result[:analysis_type] = @analysis_type
        JSON.generate(result)
      end
    end
  end
end
