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
        # ##################################################
        # CyberReport related methods.
        # ##################################################
        def getAllCyberReports(friendlyResourceId, page, pageSize)
          FriendlyResource.find(friendlyResourceId).dos_interpretation_data.paginate(:page => page, :per_page => pageSize)
        end
        def getCyberReportByTypeAndId(cyberReportType, cyberReportId)
          CyberReport.findSpecificReport(cyberReportType, cyberReportId)
        end
        def getCyberReportDetails(cyberReport)
          CyberReport.getDetailsForSpecificReport(cyberReport)
        end
      end # ArchiveApi
    end # Archive
  end # Demo
end # Departments