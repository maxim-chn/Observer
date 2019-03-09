# frozen_string_literal: true

require 'ipaddr'

##
# Holds helper methods for friendly resources view template.
module FriendlyResourcesHelper
  # @return [String]
  def friendly_resource_name(friendly_resource)
    return friendly_resource.name if friendly_resource

    'Unknown'
  end

  # @return [String]
  def friendly_resource_ip(friendly_resource)
    return IPAddr.new(friendly_resource.ip_address, Socket::AF_INET).to_s if friendly_resource

    'Unknown'
  end

  # @return [String]
  def page_title_for_friendly_resources_view(page_details)
    "FriendlyResources | #{page_details}"
  end
end
