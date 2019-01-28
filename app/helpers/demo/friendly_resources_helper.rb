# frozen_string_literal: true

require 'ipaddr'

module Demo
  ##
  # Holds helper methods for friendly resources view template.
  class FriendlyResourcesHelper
    def friendly_resource_name(friendly_resource)
      return friendlyResource.name if friendly_resource

      'Unknown'
    end

    def friendly_resource_ip(friendly_resource)
      IPAddr.new(friendly_resource.ip_address, Socket::AF_INET).to_s if friendly_resource
      'Unknown'
    end

    def page_title_for_friendly_resources_view(page_details)
      "FriendlyResources | #{page_details}"
    end
  end
end
