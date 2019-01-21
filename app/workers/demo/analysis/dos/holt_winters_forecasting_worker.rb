module Workers
  module Demo
    module Analysis
      module Dos
        class HoltWintersForecastingWorker < Workers::Demo::WorkerWithRedis
          private
          def holtWintersForecastStep(actualValue, lastCyberReport, latestCyberReport, cyberReportAtPrevSeason, cyberReportAtPrevSeasonForNextStep)
            # We are relating to current moment as T,
            # length of 1 season is M
            # Retrieve data holtWintersForecastStep at T-1 (previous step)
            previousBaseline         = getBaseline(lastCyberReport)
            previousLinearTrend      = getLinearTrend(lastCyberReport)
            estimatedValue           = getEstimatedValue(lastCyberReport)
            confidenceBandUpperValue = getConfidenceBandUpperValue(lastCyberReport)
            logger.debug("#{self.class.name} - #{__method__} - passed data extraction at T-1.")
            # Retrieve data from holtWintersForecastStep at T-M (step at previous season)
            seasonalTrendAtPrevSeason           = getSeasonalTrend(cyberReportAtPrevSeason)
            weightedAvgAbsDeviationAtPrevSeason = getWeightedAvgAbsDeviation(cyberReportAtPrevSeason)
            logger.debug("#{self.class.name} - #{__method__} - passed data extraction at T-M.")
            # Retrieve data from holtWintersForecastStep at T-M+1 (next step, at previous season)
            seasonalTrendForNextStepAtPrevSeason = getSeasonalTrend(cyberReportAtPrevSeasonForNextStep)
            logger.debug("#{self.class.name} - #{__method__} - passed data extraction at T-M+1.")
            # Perform calculations
            holtWintersForecastingApi = Algorithms::HoltWintersForecasting::Api.instance()
            logger.debug("#{self.class.name} - #{__method__} - #{actualValue} > #{confidenceBandUpperValue}.")
            aberrantBehavior = holtWintersForecastingApi.isAberrantBehavior(
              actualValue, confidenceBandUpperValue
            )
            baseline = holtWintersForecastingApi.getBaseline(
              actualValue, seasonalTrendAtPrevSeason, previousBaseline, previousLinearTrend
            )
            linearTrend = holtWintersForecastingApi.getLinearTrend(
              baseline, previousBaseline, previousLinearTrend
            )
            seasonalTrend = holtWintersForecastingApi.getSeasonalTrend(
              actualValue, baseline, seasonalTrendAtPrevSeason
            )
            confidenceBandUpperValueForNextStep = holtWintersForecastingApi.getConfidenceBandUpperValue(
              estimatedValue, weightedAvgAbsDeviationAtPrevSeason
            )
            weightedAvgAbsDeviation = holtWintersForecastingApi.getWeightedAvgAbsDeviation(
              actualValue, estimatedValue, weightedAvgAbsDeviationAtPrevSeason
            )
            estimatedValueForNextStep = holtWintersForecastingApi.getEstimatedValue(
              baseline, linearTrend, seasonalTrendForNextStepAtPrevSeason
            )
            logger.debug("#{self.class.name} - #{__method__} - passed calculations for new cyber report.")
            # Update latest interpretation data with calculations
            latestCyberReport.actual_value                = actualValue
            latestCyberReport.baseline                    = baseline
            latestCyberReport.confidence_band_upper_value = confidenceBandUpperValueForNextStep
            latestCyberReport.estimated_value             = estimatedValueForNextStep
            latestCyberReport.aberrant_behavior           = aberrantBehavior
            latestCyberReport.linear_trend                = linearTrend
            latestCyberReport.seasonal_trend              = seasonalTrend
            latestCyberReport.weighted_avg_abs_deviation  = weightedAvgAbsDeviation
            logger.debug("#{self.class.name} - #{__method__} - assigned calculations for new cyber report.")
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
        end # HoltWintersForecastingWorker
      end # Dos
    end # Analysis
  end # Demo
end # Workers