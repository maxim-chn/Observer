# frozen_string_literal: true

require 'singleton'

module Departments
  module Archive
    module Services
      ##
      # Contains validation methods for {Departments::Archive} module.
      class Validation
        include Singleton

        def friendly_resource_name?(name)
          return if name.class == String && name.size.positive?

          throw StandardError.new("#{self.class.name} - #{__method__} - #{name} must be\
            an instance of #{String.name}.")
        end

        def friendly_resource_ip_address?(ip_address)
          if ip_address.class == Integer
            return if ip_address.positive?
          end

          if ip_address.class == String
            return if ip_address.match?(/^[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*$/)
          end

          throw StandardError.new("#{self.class.name} - #{__method__} - #{ip_address} \
            does not match expected format.")
        end

        def integer?(value)
          return if value.class == Integer

          throw StandardError.new("#{self.class.name} - #{__method__} - #{value} must be\
            an instance of #{Integer.name}.")
        end

        def cyber_report?(report)
          return if report.class < CyberReport

          throw StandardError.new("#{self.class.name} - #{__method__} - #{report} must be\
            an instance of #{CyberReport.name}.")
        end

        def page?(value)
          integer?(value)
          return if value.positive?

          throw StandardError.new("#{self.class.name} - #{__method__} - #{value} must be\
            an instance of #{Integer.name} greater than 0.")
        end

        def page_size?(value)
          integer?(value)
          return if value.positive?

          throw StandardError.new("#{self.class.name} - #{__method__} - #{value} must be\
            an instance of #{Integer.name} greater than 0.")
        end

        def hash?(value)
          return if value.class == Hash

          throw StandardError.new("#{self.class.name} - #{__method__} - #{value} must be\
            an instance of #{Hash.name}.")
        end

        def friendly_resource?(friendly_resource)
          return if friendly_resource.class == FriendlyResource

          throw StandardError.new("#{self.class.name} - #{__method__} - #{friendly_resource} must be\
            an instance of #{FriendlyResource.name}.")
        end

        def cyper_report_type?(type)
          return if Shared::AnalysisType.formats.include?(type)

          throw StandardError.new("#{self.class.name} - #{__method__} - #{type} must be\
            of one of #{Shared::AnalysisType.name} formats.")
        end

        def seasonal_index_in_opts?(opts)
          return if opts.key?('seasonal_index')

          throw StandardError.new("#{self.class.name} - #{__method__} - #{opts} must contain the key\
            seasonal_index.")
        end

        def id?(value)
          integer?(value)
          return if value >= 0

          throw StandardError.new("#{self.class.name} - #{__method__} - #{value} must be\
            a non-negative #{Integer.name}.")
        end
      end
    end
  end
end
