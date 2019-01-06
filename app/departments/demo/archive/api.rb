require 'singleton'
require_relative './archive_services/services'
module Departments
  module Demo
    module Archive
      class Api
        include Singleton
        # ##################################################
        # FriendlyResource related methods.
        # ##################################################
        def getAllFriendlyResources(page, pageSize)
          FriendlyResource.paginate(:page => page, :per_page => pageSize)
        end
        def getFriendlyResourceByCyberReport(cyberReport)
          @cyberReport.friendly_resource()
        end
        def getFriendlyResourceById(friendlyResourceId)
          FriendlyResource.find(friendlyResourceId)
        end
        def getFriendlyResourceByIp(friendlyResourceIp)
          FriendlyResource.find_by(ip_address: friendlyResourceIp)
        end
        # ##################################################
        # CyberReport related methods.
        # ##################################################
        def getAllCyberReports(friendlyResourceId, page, pageSize)
          result = []
          friendlyResource = getFriendlyResourceById(friendlyResourceId)
          if friendlyResource
            result = friendlyResource.dos_icmp_interpretation_data.paginate(
              :page => page, :per_page => pageSize
            )
          end
          return result
        end
        def getCyberReportByIdAndType(cyberReportId, cyberReportType)
          cyberReport = nil
          case cyberReportType
          when Departments::Demo::Shared::AnalysisType::ICMP_DOS_CYBER_REPORT
            cyberReport = getIcmpInterpretationDataById(cyberReportId)
          end
          return cyberReport
        end
        def getCyberReportByFriendlyResourceIpAndTypeAndCustomAttributeValue(friendlyResourceIp, cyberReportType, opts)
          result           = nil
          friendlyResource = getFriendlyResourceByIp(friendlyResourceIp)
          unless friendlyResource
            throw Exception.new("#{self.class.name} - #{__method__} - no friendly resource for ip : #{friendlyResourceIp}.")
          end
          case cyberReportType
          when Departments::Demo::Shared::AnalysisType::ICMP_DOS_CYBER_REPORT
            result = getLatestIcmpInterpretationDataByFriendlyResourceIpAndSeasonalIndex(
              friendlyResource.id, opts[:seasonalIndex]
            )
          end
          return result
        end
        def getNewCyberReportObject(friendlyResourceIp, cyberReportType, opts)
          result = nil
          friendlyResource = getFriendlyResourceByIp(friendlyResourceIp)
          unless friendlyResource
            throw Exception.new("#{self.class.name} - #{__method__} - no friendly resource for ip : #{friendlyResourceIp}.")
          end
          case cyberReportType
          when Departments::Demo::Shared::AnalysisType::ICMP_DOS_CYBER_REPORT
            result = getNewIcmpInterpretationDataObject(
              opts[:seasonalIndex]
            )
            if result
              friendlyResource.dos_icmp_interpretation_data << result
            end
          end
          return result
        end
        def persistCyberReport(cyberReport)
          cyberReport.save()
        end
        private
        # ##################################################
        # DosIcmpInterpretation related methods.
        # It is not in separate file, because then Dos::Icmp::DosIcmpInterpretation
        # is not found for some reason.
        # ##################################################
        def getIcmpInterpretationDataById(cyberReportId)
          Dos::Icmp::DosIcmpInterpretation.find(cyberReportId)
        end
        def getNewIcmpInterpretationDataObject(seasonalIndex)
          result = nil
          if seasonalIndex
            result = Dos::Icmp::DosIcmpInterpretation.new(
              seasonal_index: seasonalIndex,
              report_type: Departments::Demo::Shared::AnalysisType::ICMP_DOS_CYBER_REPORT
            )
          else
            throw Exception.new("#{self.class.name} - #{__method__} - seasonalIndex must have a value.")
          end
          return result
        end
        def getLatestIcmpInterpretationDataByFriendlyResourceIpAndSeasonalIndex(friendlyResourceId, seasonalIndex)
          result = nil
          if (friendlyResourceId.nil? || seasonalIndex.nil?)
            throw Exception.new("#{self.class.name} - #{__method__} - friendlyResourceId and seasonalIndex must have values.")
          else
            queryResult = Dos::Icmp::DosIcmpInterpretation.where('friendly_resource_id = ? AND seasonal_index = ?', friendlyResourceId, seasonalIndex)
                            .limit(1)
                            .order('created_at desc')
            result = queryResult.to_a.first
          end
          return result
        end
      end # ArchiveApi
    end # Archive
  end # Demo
end # Departments