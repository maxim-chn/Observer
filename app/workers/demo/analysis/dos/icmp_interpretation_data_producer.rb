module Workers
  module Demo
    module Analysis
      module Dos
        class IcmpInterpretationDataProducer < Workers::Demo::Analysis::Dos::HoltWintersForecastingWorker
          # The worker subscribes to channel "[IP]_dosIcmpRawData".
          # Messages in "[IP]_dosIcmpRawData" are strings that can be parsed as JSON.
          # Message format is:
          # '{"continueAnalysis": boolean,
          #   "intelligenceData":[{"sourceIp": integer, "destinationIp": integer, "bodyLengthInBytes": integer}]}'
          include Sidekiq::Worker
          sidekiq_options retry: false
  
          def perform(friendlyResourceIp, redisChannel, typeOfDosCyberReport)
            logger.info("#{self.class.name} - #{__method__} - friendlyResourceIp : #{friendlyResourceIp}, redisChannel : #{redisChannel}, typeOfDosCyberReport : #{typeOfDosCyberReport}")
            redisClient = nil
            begin
              redisClient = getRedisClient()
            rescue Exception => e
              logger.error("#{self.class.name} - #{__method__} - failed to get redisClient - reason - #{e.inspect()}")
              return
            end
            redisClient.subscribe(redisChannel) do |on|
              on.message do |channel, messageRaw|
                begin
                  message = eval(messageRaw)
                  if message[:continueAnalysis]
                    holtWintersForecastingApi = Algorithms::HoltWintersForecasting::Api.instance()
                    currentSeasonalIndex      = holtWintersForecastingApi.getSeasonalIndex()
                    previousSeasonalIndex     = holtWintersForecastingApi.getPreviousSeasonalIndex(currentSeasonalIndex)
                    nextSeasonalIndex         = holtWintersForecastingApi.getNextSeasonalIndex(currentSeasonalIndex)
                    logger.debug("#{self.class.name} - #{__method__} - seasonal indices - : previous : #{previousSeasonalIndex}, current : #{currentSeasonalIndex}, next #{nextSeasonalIndex}")
                    archiveApi = Departments::Demo::Archive::Api.instance()
                    lastCyberReport = archiveApi.getCyberReportByFriendlyResourceIpAndTypeAndCustomAttributeValue(
                      friendlyResourceIp, typeOfDosCyberReport, seasonalIndex: previousSeasonalIndex
                    )
                    logger.debug("#{self.class.name} - #{__method__} - cyber report at T-1 : #{lastCyberReport.inspect()}")
                    cyberReportAtPrevSeason = archiveApi.getCyberReportByFriendlyResourceIpAndTypeAndCustomAttributeValue(
                      friendlyResourceIp, typeOfDosCyberReport, seasonalIndex: currentSeasonalIndex
                    )
                    logger.debug("#{self.class.name} - #{__method__} - cyber report at T-M : #{cyberReportAtPrevSeason.inspect()}")
                    cyberReportAtPrevSeasonForNextStep = archiveApi.getCyberReportByFriendlyResourceIpAndTypeAndCustomAttributeValue(
                      friendlyResourceIp, typeOfDosCyberReport, seasonalIndex: nextSeasonalIndex
                    )
                    logger.debug("#{self.class.name} - #{__method__} - cyber report at T-M+1 : #{cyberReportAtPrevSeasonForNextStep.inspect()}")
                    latestCyberReport = archiveApi.getNewCyberReportObject(
                      friendlyResourceIp, typeOfDosCyberReport, seasonalIndex: currentSeasonalIndex
                    )
                    logger.debug("#{self.class.name} - #{__method__} - initialized new cyber report object : #{latestCyberReport.inspect()}")
                    actualIcmpRequests = countIncomingIcmpRequests(message[:intelligenceData], friendlyResourceIp)
                    logger.debug("#{self.class.name} - #{__method__} - counted amount of ICMP requests : #{actualIcmpRequests}")
                    holtWintersForecastStep(
                      actualIcmpRequests, lastCyberReport, latestCyberReport, cyberReportAtPrevSeason, cyberReportAtPrevSeasonForNextStep
                    )
                    archiveApi.persistCyberReport(latestCyberReport)
                    logger.debug("#{self.class.name} - #{__method__} - persisted #{latestCyberReport.inspect()}.")
                  else
                    redisClient.unsubscribe(channel)
                    logger.info("#{self.class.name} - #{__method__} - unsubscribed from channel : #{channel}")
                  end
                rescue Exception => e
                  logger.error("#{self.class.name} - #{__method__} - failed to procees message from channel : #{channel}")
                  logger.error("#{self.class.name} - #{__method__} - error : #{e.inspect()}")
                  return
                end
              end
            end
          end
          private
          def countIncomingIcmpRequests(intelligenceData, friendlyResourceIp)
            result = 0
            if intelligenceData
              result = intelligenceData.select { |intelligenceEntry|
                intelligenceEntry[:destination] == friendlyResourceIp 
              }.count()
            else
              throw Exception.new("#{self.class.name} -#{__method__} - corrupted intelligenceData.")
            end
            return result
          end
        end # DosInterpretationDataProducer
      end # Dos
    end # Analysis
  end # Demo
end # Workers
