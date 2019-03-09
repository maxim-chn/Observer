# frozen_string_literal: true

module Departments
  ##
  # Holds modules and classes shared by all departments:
  # - {Departments::Analysis}
  # - {Departments::Archive}
  # - {Departments::Intelligence}
  # - {Departments::ThinkTank}
  module Shared
    ##
    # Unites arguments for {Departments::Analysis::Api}.
    # United arguments are the analysis query that specifies what type of
    # {CyberReport} we would like to get and for what {FriendlyResource}.
    class AnalysisQuery
      attr_reader :friendly_resource_ip, :analysis_type

      def initialize(friendly_resource_ip, analysis_type)
        @friendly_resource_ip = friendly_resource_ip
        @analysis_type = analysis_type
      end

      # Textual representaion of an object.
      # @return [String]
      def inspect
        result = {}
        result[:friendly_resource_ip] = @friendly_resource_ip
        result[:analysis_type] = @analysis_type
        JSON.generate(result)
      end
    end
  end
end
