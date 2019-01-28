# frozen_string_literal: true

module Demo
  module BackendApi
    ##
    # This class consumes [ThinkTankApi].
    # It receives intelligence data, related to ICMP requests, and
    # initiates its analysis with [ThinkTankApi].
    class DosIcmpIntelligenceController < ApplicationController
      # Otherwise, POST requests from resource files outside our server are blocked.
      skip_before_action :verify_authenticity_token
      # +params+ - a [Hash] object with ICMP requests intelligence.
      # It comes from POST request payload.
      def create
        intelligence_data = params[:intelligence_data]
        if intelligence_data
          render plain: 'DOS ICMP Intelligence Data Received'
        else
          render plain: 'DOS ICMP Intelligence Data Not Received'
        end
      end
    end
  end
end
