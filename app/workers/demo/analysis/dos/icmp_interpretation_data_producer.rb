require 'redis'

module Workers
  module Demo
    module Analysis
      module Dos
        class IcmpInterpretationDataProducer
          # The worker subscribes to channel "[IP]_dosIcmpRawData".
          # Messages in "[IP]_dosIcmpRawData" are strings that can be parsed as JSON.
          # Message format is:
          # '{"continueAnalysis": boolean,
          #   "intelligenceData":[{"sourceIp": integer, "destinationIp": integer, "bodyLengthInBytes": integer}]}'
          include Sidekiq::Worker
          sidekiq_options retry: false
  
          def perform(friendlyResourceIp, redisChannel, typeOfDosCyberReport)
            logger.info("IcmpInterpretationDataProducer - friendlyResourceIp : #{friendlyResourceIp}, redisChannel : #{redisChannel}, typeOfDosCyberReport : #{typeOfDosCyberReport}")
            redis = Redis.new(:host => 'localhost', :port => '6379', :timeout => 0)
            redis.subscribe(redisChannel) do |on|
              on.message do |channel, messageRaw|
                begin
                  message = eval(messageRaw)
                  if message[:continueAnalysis]
                    archiveApi      = Departments::Demo::Archive::ArchiveApi.instance()
                    lastCyberReport = archiveApi.getCyberReportByFriendlyResourceIpAndType(
                      friendlyResourceIp, typeOfDosCyberReport
                    )
                    logger.debug("IcmpInterpretationDataProducer - cyber report at T-1 : #{lastCyberReport.inspect()}")
                    currentSeasonalIndex    = getCurrentSeasonalIndex(lastCyberReport)
                    cyberReportAtPrevSeason = archiveApi.getCyberReportByFriendlyResourceIpAndTypeAndCustomAttributeValue(
                      friendlyResourceIp, typeOfDosCyberReport, seasonalIndex: currentSeasonalIndex
                    )
                    logger.debug("IcmpInterpretationDataProducer - cyber report at T-M : #{cyberReportAtPrevSeason.inspect()}")
                    cyberReportAtPrevSeasonForNextStep = archiveApi.getCyberReportByFriendlyResourceIpAndTypeAndCustomAttributeValue(
                      friendlyResourceIp, typeOfDosCyberReport, seasonalIndex: currentSeasonalIndex + 1
                    )
                    logger.debug("IcmpInterpretationDataProducer - cyber report at T-M+1 : #{cyberReportAtPrevSeason.inspect()}")
                    latestCyberReport = archiveApi.getNewCyberReportObject(
                      typeOfDosCyberReport, seasonalIndex: currentSeasonalIndex
                    )
                    logger.debug("IcmpInterpretationDataProducer - initialized new cyber report object : #{latestCyberReport.inspect()}")
                    actualIcmpRequests = countIncomingIcmpRequests(message[:intelligenceData], friendlyResourceIp)
                    logger.debug("IcmpInterpretationDataProducer - counted amount of ICMP requests : #{actualIcmpRequests}")
                    holtWintersForecastStep(
                      actualIcmpRequests, lastCyberReport, latestCyberReport, cyberReportAtPrevSeason, cyberReportAtPrevSeasonForNextStep
                    )
                    archiveApi.persistCyberReport(friendlyResourceIp, latestCyberReport)
                  else
                    redis.unsubscribe(channel)
                    logger.info("IcmpInterpretationDataProducer - unsubscribed from channel : #{channel}")
                  end
                rescue Exception => e
                  logger.error("IcmpInterpretationDataProducer - failed to procees message from channel : #{channel}")
                  logger.error("IcmpInterpretationDataProducer - error : #{e.inspect()}")
                  return
                end
              end
            end
          end
          private
          def getCurrentSeasonalIndex(lastCyberReport)
            if lastCyberReport
              if lastCyberReport.seasonal_index
                return lastCyberReport.seasonal_index + 1
              end
            end
            return 0
          end
          def countIncomingIcmpRequests(intelligenceData, friendlyResourceIp)
            result = 0
            if intelligenceData
              result = intelligenceData.select { |intelligenceEntry|
                intelligenceEntry[:destination] == friendlyResourceIp 
              }.count()
            else
              throw Exception.new('countIncomingIcmpRequests() - corrupted intelligenceData.')
            end
            return result
          end
          def holtWintersForecastStep(actualValue, lastCyberReport, latestCyberReport, cyberReportAtPreviousSeason, cyberReportAtPreviousSeasonForNextStep)
            # We are relating to current moment as T,
            # length of 1 season is M
            # Retrieve data holtWintersForecastStep at T-1 (previous step)
            previousBaseline         = getBaseline(lastCyberReport)
            previousLinearTrend      = getLinearTrend(lastCyberReport)
            estimatedValue           = getEstimatedValue(lastCyberReport)
            confidenceBandUpperValue = getConfidenceBandUpperValue(lastCyberReport)
            # Retrieve data from holtWintersForecastStep at T-M (step at previous season)
            seasonalTrendAtPreviousSeason           = getSeasonalTrend(cyberReportAtPreviousSeason)
            weightedAvgAbsDeviationAtPreviousSeason = getWeightedAvgAbsDeviation(cyberReportAtPreviousSeason)
            # Retrieve data from holtWintersForecastStep at T-M+1 (next step, at previous season)
            seasonalTrendForNextStepAtPreviousSeason = getSeasonalTrend(cyberReportAtPreviousSeasonForNextStep)
            # Perform calculations
            holtWintersForecastingApi = Algorithms::HoltWintersForecasting::Api.instance()
            aberrantBehavior = holtWintersForecastingApi.isAberrantBehavior(
              actualValue, confidenceBandUpperValue
            )
            baseline = holtWintersForecastingApi.getBaseline(
              actualValue, seasonalTrendAtPreviousSeason, previousBaseline, previousLinearTrend
            )
            linearTrend = holtWintersForecastingApi.getLinearTrend(
              baseline, previousBaseline, previousLinearTrend
            )
            seasonalTrend = holtWintersForecastingApi.getSeasonalTrend(
              actualValue, baseline, seasonalTrendAtPreviousSeason
            )
            confidenceBandUpperValueForNextStep = holtWintersForecastingApi.getConfidenceBandUpperValue(
              estimatedValue, weightedAvgAbsDeviationAtPreviousSeason
            )
            weightedAvgAbsDeviation = holtWintersForecastingApi.getWeightedAvgAbsDeviation(
              actualValue, estimatedValue, weightedAvgAbsDeviationAtPreviousSeason
            )
            estimatedValueForNextStep = holtWintersForecastingApi.getEstimatedValue(
              baseline, linearTrend, seasonalTrendForNextStepAtPreviousSeason
            )
            # Update latest interpretation data with calculations
            latestCyberReport.actual_value                = actualValue
            latestCyberReport.baseline                    = baseline
            latestCyberReport.confidence_band_upper_value = confidenceBandUpperValueForNextStep
            latestCyberReport.estimated_value             = estimatedValueForNextStep
            latestCyberReport.aberrant_behavior           = aberrantBehavior
            latestCyberReport.linear_trend                = linearTrend
            latestCyberReport.seasonal_trend              = seasonalTrend
            latestCyberReport.weighted_avg_abs_deviation  = weightedAvgAbsDeviation
          end
          def getBaseline(interpretationData)
            if interpretationData
              if interpretationData.baseline
                return interpretationData.baseline
              end
            end
            return 0
          end
          def getLinearTrend(interpretationData)
            if interpretationData
              if interpretationData.linear_trend
                return interpretationData.linear_trend
              end
            end
            return 0
          end
          def getEstimatedValue(interpretationData)
            if interpretationData
              if interpretationData.estimated_value
                return interpretationData.estimated_value
              end
            end
            return 0
          end
          def getConfidenceBandUpperValue(interpretationData)
            if interpretationData
              if interpretationData.confidence_band_upper_value
                return interpretationData.confidence_band_upper_value
              end
            end
            return nil
          end
          def getSeasonalTrend(interpretationData)
            if interpretationData
              if interpretationData.seasonal_trend
                return interpretationData.seasonal_trend
              end
            end
            return 0
          end
          def getWeightedAvgAbsDeviation(interpretationData)
            if interpretationData
              if interpretationData.weighted_avg_abs_deviation
                return interpretationData.weighted_avg_abs_deviation
              end
            end
            return 0
          end
        end # DosInterpretationDataProducer
      end # Dos
    end # Analysis
  end # Demo
end # Workers
