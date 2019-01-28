# frozen_string_literal: true

module Departments
  module Demo
    module Shared
      ##
      # Objects of this class are inputs for right consumption of [IntelligenceApi].
      class IntelligenceQuery
        attr_reader :friendly_resource_ip, :collect_format

        def initialize(friendly_resource_ip, collect_format)
          @friendly_resource_ip = friendly_resource_ip
          @collect_format = collect_format
        end

        # Gives a [String] representaion of an object.
        def inspect
          result = {}
          result[:friendly_resource_ip] = @friendly_resource_ip
          result[:collect_format] = @collect_format
          JSON.generate(result)
        end
      end
    end
  end
end
