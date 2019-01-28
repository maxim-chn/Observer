# frozen_string_literal: true

require 'singleton'
require_relative './services/analysis.rb'
require_relative './services/intelligence.rb'

module Departments
  module Demo
    module ThinkTank
      ##
      # This is an [API] for consumption by other Observer modules.
      class Api
        include Singleton

        # Passes data to be collected to [FieldAgent].
        # +id+ - friendly resource id in the database.
        # It will be available, because [FriendlyResourceController]
        # is the sole expected consumer of this method.
        def start_monitoring(id)
          Rails.logger.info("#{self.class.name} - #{__method__} - id : #{id}")
          archive_api = Departments::Demo::Archive::Api.instance
          friendly_resource = archive_api.get_friendly_resource_by_id(id)
          intelligence_services = Services::Intelligence.instance
          intelligence_services.gather_dos_intelligence(friendly_resource.ip_address)
        end

        # Passes data to not be collected to [FieldAgent].
        # +id+ - friendly resource id in the database.
        # It will be available, because [FriendlyResourceController]
        # is the sole expected consumer of this method.
        def stop_monitoring(id)
          Rails.logger.info("#{self.class.name} - #{__method__} - id : #{id}")
          archive_api = Departments::Demo::Archive::Api.instance
          friendly_resource = archive_api.get_friendly_resource_by_id(id)
          intelligence_services = Services::Intelligence.instance
          intelligence_services.stop_dos_intelligence_gathering(friendly_resource.ip_address)
        end
      end
    end
  end
end
