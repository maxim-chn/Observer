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

          error_message = "#{self.class.name} - #{__method__} - #{name} must be an instance of #{String.name}."
          throw StandardError.new(error_message)
        end

        def friendly_resource_ip_address?(ip_address)
          if ip_address.class == Integer
            return if ip_address.positive?
          end

          if ip_address.class == String
            return if ip_address.match?(/^[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*$/)
          end

          error_message = "#{self.class.name} - #{__method__} - #{ip_address} does not match expected format."
          throw StandardError.new(error_message)
        end

        def integer?(value)
          return if value.class == Integer

          error_message = "#{self.class.name} - #{__method__} - #{value} must be an instance of #{Integer.name}."
          throw StandardError.new(error_message)
        end

        def cyber_report?(report)
          return if report.class < CyberReport

          error_message = "#{self.class.name} - #{__method__} - #{report} must be an instance of #{CyberReport.name}."
          throw StandardError.new(error_message)
        end

        def page?(value)
          integer?(value)
          return if value.positive?

          error_message = "#{self.class.name} - #{__method__} - #{value}"
          error_message += " must be an instance of #{Integer.name} greater than 0."
          throw StandardError.new(error_message)
        end

        def page_size?(value)
          integer?(value)
          return if value.positive?

          error_message = "#{self.class.name} - #{__method__} - #{value}"
          error_message += " must be an instance of #{Integer.name} greater than 0."
          throw StandardError.new(error_message)
        end

        def hash?(value)
          return if value.class == Hash

          error_message = "#{self.class.name} - #{__method__} - #{value} must be an instance of #{Hash.name}."
          throw StandardError.new(error_message)
        end

        def friendly_resource?(friendly_resource)
          return if friendly_resource.class == FriendlyResource

          error_message = "#{self.class.name} - #{__method__} - #{friendly_resource}"
          error_message += " must be an instance of #{FriendlyResource.name}."
          throw StandardError.new(error_message)
        end

        def cyper_report_type?(type)
          return if Shared::AnalysisType.formats.include?(type)

          error_message = "#{self.class.name} - #{__method__} - #{type}"
          error_message += " must be one of #{Shared::AnalysisType.name} formats."
          throw StandardError.new(error_message)
        end

        def seasonal_index_in_opts?(opts)
          return if opts.key?('seasonal_index')

          error_message = "#{self.class.name} - #{__method__} - #{opts} must contain the key seasonal_index."
          throw StandardError.new(error_message)
        end

        def seasonal_index?(value)
          hw_forecasting_api = Algorithms::HoltWintersForecasting::Api.instance
          min = hw_forecasting_api.min_seasonal_index(Algorithms::HoltWintersForecasting::ICMP_FLOOD)
          max = hw_forecasting_api.max_seasonal_index(Algorithms::HoltWintersForecasting::ICMP_FLOOD)
          if value.class == Integer
            return if value >= min && value <= max
          end

          error_message = "#{self.class.name} - #{__method__} - #{value}"
          error_message += " must be an #{Integer.name} in range [#{min},#{max}]."
          throw StandardError.new(error_message)
        end

        def id?(value)
          integer?(value)
          return if value >= 0

          error_message = "#{self.class.name} - #{__method__} - #{value} must be a non-negative #{Integer.name}."
          throw StandardError.new(error_message)
        end

        def custom_attributes?(opts)
          return if opts.class == Hash

          throw StandardError.new("#{self.class.name} - #{__method__} - #{opts} must be of #{Hash.name} type.")
        end
      end
    end
  end
end
