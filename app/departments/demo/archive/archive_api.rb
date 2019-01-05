require 'singleton'
module Departments
  module Demo
    module Archive
      class ArchiveApi
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
          FriendlyResource.find(friendlyResourceId).dos_icmp_interpretation_data.paginate(:page => page, :per_page => pageSize)
        end
        def getCyberReportByTypeAndId(cyberReportType, cyberReportId)
          CyberReport.findSpecificReport(cyberReportType, cyberReportId)
        end
        def getCyberReportByFriendlyResourceIpAndType(friendlyResourceIp, cyberReportType)
          friendlyResource = FriendlyResource.find_by(ip_address: friendlyResourceIp)
          unless friendlyResource
            throw Exception.new("ArchiveApi - getCyberReportByFriendlyResourceIpAndType() - no friendly resource for ip : #{friendlyResourceIp}.")
          end
          return friendlyResource.getLatestDosCyberReport(cyberReportType)
        end
        def getCyberReportByFriendlyResourceIpAndTypeAndCustomAttributeValue(friendlyResourceIp, cyberReportType, opts)
          result = nil
          friendlyResource = getFriendlyResourceByIp(friendlyResourceIp)
          unless friendlyResource
            throw Exception.new("ArchiveApi - getCyberReportByFriendlyResourceIpAndTypeAndCustomAttributeValue() - no friendly resource for ip : #{friendlyResourceIp}.")\
          end
          case cyberReportType
          when Dos::DosReport::ICMP_DOS_CYBER_REPORT
            result = getLatestIcmpInterpretationDataByFriendlyResourceIpAndSeasonalIndex(
              friendlyResource.id, opts[:seasonalIndex]
            )
          end
          return result
        end
        def getCyberReportDetails(cyberReport)
          CyberReport.getDetailsForSpecificReport(cyberReport)
        end
        def getNewCyberReportObject(friendlyResourceIp, cyberReportType, opts)
          result = nil
          friendlyResource = FriendlyResource.find_by(ip_address: friendlyResourceIp)
          unless friendlyResource
            throw Exception.new("ArchiveApi - getCyberReportByFriendlyResourceIpAndType() - no friendly resource for ip : #{friendlyResourceIp}.")
          end
          case cyberReportType
          when Dos::DosReport::ICMP_DOS_CYBER_REPORT
            result = getNewIcmpInterpretationDataObject(opts[:seasonalIndex])
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
        # CyberReport related methods.
        # ##################################################
        def getNewIcmpInterpretationDataObject(seasonalIndex)
          result = nil
          if seasonalIndex
            if (seasonalIndex == Dos::DosReport::SEASON_DURATION_IN_SECONDS)
              seasonalIndex = Dos::DosReport::FIRST_SEASONAL_INDEX
            end
            result = Dos::Icmp::DosIcmpInterpretation.new(seasonal_index: seasonalIndex)
          else
            throw Exception.new('ArchiveApi - getNewIcmpInterpretationDataObject() - seasonalIndex must have a value.')
          end
          return result
        end
        def getLatestIcmpInterpretationDataByFriendlyResourceIpAndSeasonalIndex(friendlyResourceId, seasonalIndex)
          result = nil
          if seasonalIndex.nil? || friendlyResourceId.nil?
            throw Exception.new('ArchiveApi - getLatestIcmpInterpretationDataByFriendlyResourceIpAndSeasonalIndex() - friendlyResourceId and seasonalIndex must have values.')
          else
            queryResult = Dos::Icmp::DosIcmpInterpretation.where('friendly_resource_id = ? AND seasonal_index = ?', friendlyResourceId, seasonalIndex)
                            .limit(1)
                            .order('created_at desc')
            result = queryResult.to_a.first
          end
          return result
        end
        def persistIcmpInterpretationDataObject(interpretationData)
          interpretationData.save()
        end
      end # ArchiveApi
    end # Archive
  end # Demo
end # Departments