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
          ip_address_str = ip_address.to_s
          return if ip_address_str.match?(/^[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*$/)

          return if ip_address_str.match?(/^[0-9]*$/)

          throw StandardError.new("#{self.class.name} - #{__method__} - #{ip_address} \
            does not match expected format.")
        end

        def integer?(value)
          return if value.class == Integer

          throw StandardError.new("#{self.class.name} - #{__method__} - #{value} must be\
            an instance of #{Integer.name}.")
        end
      end
    end
  end
end
