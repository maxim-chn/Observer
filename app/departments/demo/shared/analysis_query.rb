# frozen_string_literal: true

module Departments
  module Demo
    module Shared
      ##
      # Objects of this class are inputs for right consumption of [AnalysisApi].
      class AnalysisQuery
        attr_reader :friendly_resource_ip, :analysis_type

        def initialize(friendly_resource_ip, analysis_type)
          @friendly_resource_ip = friendly_resource_ip
          @analysis_type = analysis_type
        end

        # Gives a [String] representaion of an object.
        def inspect
          result = {}
          result[:friendly_resource_ip] = @friendly_resource_ip
          result[:analysis_type] = @analysis_type
          JSON.generate(result)
        end
      end
    end
  end
end
