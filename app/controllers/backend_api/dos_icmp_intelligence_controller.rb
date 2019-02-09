# frozen_string_literal: true

##
# A set of controllers that accept requests, not resulting in rendering
# any Data object.
module BackendApi
  ##
  # Manages routes for requests with intelligence data payloads. The scope of intelligence is
  # ICMP requests.
  class DosIcmpIntelligenceController < ApplicationController
    # Otherwise, POST requests from resource files outside our server are blocked.
    skip_before_action :verify_authenticity_token

    def create
      intelligence_data = {}
      intelligence_data[:incoming_req_count] = params[:incoming_req_count].to_i
      ip = params[:ip]
      if intelligence_data
        begin
          Departments::ThinkTank::Api.instance.analyze_icmp_dos_intelligence_data(ip, intelligence_data)
          render plain: 'Request to analyze succeeded'
        rescue StandardError => e
          Rails.logger.error(e.message)
          render plain: 'Request to analyze failed'
        end
      else
        render plain: 'DOS ICMP Intelligence Data Not Received'
      end
    end
  end
end
