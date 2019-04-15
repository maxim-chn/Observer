# frozen_string_literal: true

##
# A set of controllers that accept requests, not resulting in rendering any Data object.
module BackendApi
  ##
  # Manages routes for requests with intelligence data payloads. The scope of intelligence is ICMP requests.
  class DosIcmpIntelligenceController < ApplicationController
    # Otherwise, POST requests from resource files outside our server are blocked.
    skip_before_action :verify_authenticity_token

    # Runs a background job to create {Dos::IcmpFloodReport}.
    # Necessary parameters come from a POST request.
    def create
      intelligence_data = {}
      intelligence_data['incoming_req_count'] = params[:incoming_req_count].to_i if params[:incoming_req_count]
      ip = params[:ip].to_i if params[:ip]
      message = { 'result' => '', 'continue_collection' => '' }
      think_tank = Departments::ThinkTank::Api.instance
      if intelligence_data
        begin
          message['continue_collection'] = think_tank.icmp_dos_intelligence_collection?(ip)
          if message['continue_collection']
            think_tank.analyze_icmp_dos_intelligence_data(ip, intelligence_data)
            message['result'] = 'Request to analyze succeeded'
          end
        rescue StandardError => e
          Rails.logger.error(e.message)
          message['result'] = 'Request to analyze failed'
        end
      else
        message['result'] = 'DOS ICMP intelligence data not received'
        message['continue_collection'] = false
      end
      render plain: JSON.generate(message)
    end
  end
end
