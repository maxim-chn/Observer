# frozen_string_literal: true

require 'singleton'

module Departments
  module Archive
    module Services
      ##
      # This class consumes models that extend Dos::DosReport.
      class IcmpFloodReport
        include Singleton

        # Dos::IcmpFloodReport related methods.
        def icmp_flood_report_by_id(id)
          Dos::IcmpFloodReport.find(id)
        end

        def new_report_object(seasonal_index)
          if seasonal_index
            return Dos::IcmpFloodReport.new(
              seasonal_index: seasonal_index,
              report_type: Shared::AnalysisType::ICMP_DOS_CYBER_REPORT
            )
          end
          throw StandardError.new("#{self.class.name} - #{__method__} - seasonal_index\
            must have a value.")
        end

        def latest_report_by_friendly_resource_id_and_seasonal_index(
          id,
          seasonal_index
        )
          if id.nil? || seasonal_index.nil?
            throw StandardError.new("#{self.class.name} - #{__method__} - id and seasonal_index\
              must have values.")
          end
          Dos::IcmpFloodReport.where(
            'friendly_resource_id = ? AND seasonal_index = ?',
            id,
            seasonal_index
          ).limit(1).order('created_at desc').to_a.first
        end
      end
    end
  end
end
