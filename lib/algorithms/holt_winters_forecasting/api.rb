require 'singleton'
module Algorithms
  module HoltWintersForecasting
    class Api
      include Singleton
      # ##################################################
      # Methods for affecting constants,
      # i.e. smoothing constants.
      # ##################################################
      def setHourDurationInMinutes(minutes)
        @minutesInAnHour = minutes
      end
      def setMinuteDurationInSeconds(seconds)
        @secondsInAMinute = seconds
      end
      def setIntervalBetweenCollectionsInSeconds(seconds)
        @intervalBeetweenObservationsInSeconds = seconds
      end
      def setMinSeasonalIndex(index)
        @minSeasonalIndex = index
      end
      def setMaxSeasonalIndex(index)
        @maxSeasonalIndex = index
      end
      def setAlpha(percentageOfTotalWeights, amountOfTimePoints)
        value = 1 - Math.exp((Math.log10(1 - percentageOfTotalWeights)) / amountOfTimePoints)
        validateSmoothingConstant('Alpha', 0, 1, value)
        @alpha = value
      end
      def setBeta(percentageOfTotalWeights, amountOfTimePoints)
        value = 1 - Math.exp((Math.log10(1 - percentageOfTotalWeights)) / amountOfTimePoints)
        validateSmoothingConstant('Beta', 0, 1, value)
        @beta = value
      end
      def setGamma(percentageOfTotalWeights, amountOfTimePoints)
        value = 1 - Math.exp((Math.log10(1 - percentageOfTotalWeights)) / amountOfTimePoints)
        validateSmoothingConstant('Gamma', 0, 1, value)
        @gamma = value
      end
      def setTeta(value)
        validateSmoothingConstant('Teta', 2, 3, value)
        @teta = value
      end
      # ##################################################
      # Methods that perform actual calculations.
      # ##################################################
      def getSeasonalIndex()
        hour    = DateTime.now().strftime('%H').to_i()
        minutes = DateTime.now().strftime('%M').to_i()
        seconds = DateTime.now().strftime('%S').to_i()
        return (((hour*@minutesInAnHour)+(minutes*@secondsInAMinute)+(seconds)) / @intervalBeetweenObservationsInSeconds)
      end
      def getPreviousSeasonalIndex(seasonalIndex)
        validateSeasonalIndex(seasonalIndex)
        if (seasonalIndex > @minSeasonalIndex)
          return seasonalIndex - 1
        else
          return @maxSeasonalIndex
        end
      end
      def getNextSeasonalIndex(seasonalIndex)
        validateSeasonalIndex(seasonalIndex)
        if (seasonalIndex < @maxSeasonalIndex)
          return seasonalIndex + 1
        else
          return @minSeasonalIndex
        end
      end
      def isAberrantBehavior(actualValue, confidenceBandUpperValue)
        # Is there aberrant behavior at moment T?
        # During "cold start" confidenceBandUpperValue might be nil, for the lack of prior observations.
        # We will return false in this case.
        if actualValue
          if confidenceBandUpperValue
            return actualValue > confidenceBandUpperValue
          end
          return false
        end
        throw Exception.new("#{self.class.name} - #{__method__} - actualValue must have a value.")
      end
      def getBaseline(actualValue, seasonalTrendAtPrevSeason, previousBaseline, previousLinearTrend)
        # Other terms for baseline: intercept, level.
        # We return baseline at moment T.
        # actualValue is at moment T.
        # seasonalTrendAtPrevSeason is at moment T-M.
        # previousBaseline is at moment T-1.
        # previousLinearTrend is at moment T-1.
        throw Exception.new("#{self.class.name} - #{__method__} - actualValue must have a value.") if actualValue.nil?()
        throw Exception.new("#{self.class.name} - #{__method__} - seasonalTrendAtPrevSeason must have a value.") if seasonalTrendAtPrevSeason.nil?()
        throw Exception.new("#{self.class.name} - #{__method__} - previousBaseline must have a value.") if previousBaseline.nil?()
        throw Exception.new("#{self.class.name} - #{__method__} - previousLinearTrend must have a value.") if previousLinearTrend.nil?()
        return @alpha*(actualValue-seasonalTrendAtPrevSeason)+(1-@alpha)*(previousBaseline+previousLinearTrend)
      end
      def getConfidenceBandUpperValue(estimatedValue, weightedAvgAbsDeviationAtPrevSeason)
        # We return upper value for confidence band at moment T+1.
        # estimatedValue is at moment T. It has been calculated at moment T-1.
        # weightedAvgAbsDeviationAtPrevSeason is at moment T-M.
        throw Exception.new("#{self.class.name} - #{__method__} - estimatedValue must have a value.") if estimatedValue.nil?()
        throw Exception.new("#{self.class.name} - #{__method__} - weightedAvgAbsDeviationAtPrevSeason must have a value.") if weightedAvgAbsDeviationAtPrevSeason.nil?()
        return estimatedValue+(@teta*weightedAvgAbsDeviationAtPrevSeason)
      end
      def getEstimatedValue(baseline, linearTrend, seasonalTrendForNextStepAtPrevSeason)
        # We return estimatedValue at moment T+1.
        # baseline is at moment T.
        # linearTrend is at moment T.
        # seasonalTrendForNextStepAtPrevSeason is at moment T-M+1.
        throw Exception.new("#{self.class.name} - #{__method__} - baseline must have a value.") if baseline.nil?()
        throw Exception.new("#{self.class.name} - #{__method__} - linearTrend must have a value.") if linearTrend.nil?()
        throw Exception.new("#{self.class.name} - #{__method__} - seasonalTrendForNextStepAtPrevSeason must have a value.") if seasonalTrendForNextStepAtPrevSeason.nil?()
        return (baseline+linearTrend+seasonalTrendForNextStepAtPrevSeason)
      end
      def getLinearTrend(baseline, previousBaseline, previousLinearTrend)
        # Other terms for linearTrend: slope
        # We return linear trend at moment T.
        # baseline is at moment T.
        # previousBaseline is at moment T-1.
        # previousLinearTrend is at moment T-1.
        throw Exception.new("#{self.class.name} - #{__method__} - baseline must have a value.") if baseline.nil?()
        throw Exception.new("#{self.class.name} - #{__method__} - previousBaseline must have a value.") if previousBaseline.nil?()
        throw Exception.new("#{self.class.name} - #{__method__} - previousLinearTrend must have a value.") if previousLinearTrend.nil?()
        return @beta*(baseline-previousBaseline)+((1-@beta)*previousLinearTrend)
      end
      def getSeasonalTrend(actualValue, baseline, seasonalTrendAtPrevSeason)
        # We return seasonal trend at moment T.
        # actualValue is at moment T.
        # baseline is at moment T.
        # seasonalTrendAtPrevSeason is at moment T-M.
        throw Exception.new("#{self.class.name} - #{__method__} - actualValue must have a value.") if actualValue.nil?()
        throw Exception.new("#{self.class.name} - #{__method__} - baseline must have a value.") if baseline.nil?()
        throw Exception.new("#{self.class.name} - #{__method__} - seasonalTrendAtPrevSeason must have a value.") if seasonalTrendAtPrevSeason.nil?()
        return @gamma*(actualValue-baseline)+((1-@gamma)*seasonalTrendAtPrevSeason)
      end
      def getWeightedAvgAbsDeviation(actualValue, estimatedValue, weightedAvgAbsDeviationAtPrevSeason)
        # We return weighted average absolute deviation at moment T.
        # actualValue is at moment T.
        # estimatedValue is at moment T. It has been calculated at moment T-1.
        # weightedAvgAbsDeviationAtPrevSeason is at moment T-M.
        throw Exception.new("#{self.class.name} - #{__method__} - actualValue must have a value.") if actualValue.nil?()
        throw Exception.new("#{self.class.name} - #{__method__} - estimatedValue must have a value.") if estimatedValue.nil?()
        throw Exception.new("#{self.class.name} - #{__method__} - weightedAvgAbsDeviationAtPrevSeason must have a value.") if weightedAvgAbsDeviationAtPrevSeason.nil?()
        return @gamma*(actualValue-estimatedValue).abs()+((1-@gamma)*weightedAvgAbsDeviationAtPrevSeason)
      end
      private
      def validateSmoothingConstant(constantName, minValue, maxValue, value)
        if (value < minValue || value > maxValue)
          throw Exception.new("#{self.class.name} - #{__method__} - #{constantName} must belong to [#{minValue},#{maxValue}].")
        end
      end
      def validateSeasonalIndex(seasonalIndex)
        if seasonalIndex
          if (seasonalIndex < @minSeasonalIndex || seasonalIndex > @maxSeasonalIndex)
            throw Exception.new("#{self.class.name} - #{__method__} - seasonalIndex must belong to [#{@minSeasonalIndex},#{@maxSeasonalIndex}]")
          end
        else
          throw Exception.new("#{self.class.name} - #{__method__} - seasonalIndex must have a value.")
        end
      end
    end # Api
  end # HoltWintersForecasting
end # Algorithms