# frozen_string_literal: true

module Departments
  ##
  # Holds the classes shared by all the {Departments}.
  module Shared
    ##
    # Unites the arguments for the {Departments::Analysis::Api}.
    # The united arguments are the analysis query that specifies what type of the
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
