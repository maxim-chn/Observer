require 'singleton'
module Algorithms
  module HoltWintersForecasting
    class Api
      include Singleton
      def initialize
        # This is a singleton.
        # Initialize is called once and not by directly.
        # Alpha denotes baseline smoothing.
        # A guess is that last hour of observations should have 75% of "importance".
        setAlpha(0.75, 60 * 60 / Dos::DosReport::INTERVAL_BETWEEN_COLLECTIONS_IN_SECONDS)
        # Beta denotes linear trend smoothing than 1 seasonal cycle.
        # We would not like last day observations should not have more than 50% of "importance".
        setBeta(0.5, Dos::DosReport::SEASON_DURATION_IN_SECONDS / Dos::DosReport::INTERVAL_BETWEEN_COLLECTIONS_IN_SECONDS)
        # Gamma denotes seasonal smoothing.
        # A guess is that last 7 days of observations should not have more than 50% of "importance".
        setGamma(0.5, 7 * Dos::DosReport::SEASON_DURATION_IN_SECONDS / Dos::DosReport::INTERVAL_BETWEEN_COLLECTIONS_IN_SECONDS)
        # Teta denotes scaling factor for confidence bands.
        # Value close to 2 is chosen when missing true positive is more harmful than getting a false positive.
        # Value close to 3 is chosen when getting false positive is more harmful than missing true positive.
        setTeta(2)
      end
      def setAlpha(percentageOfTotalWeights, amountOfTimePoints)
        value = 1 - Math.exp((Math.log10(1 - percentageOfTotalWeights)) / amountOfTimePoints)
        if value < 0 || value > 1
          throw Exception.new('HoltWintersForecasting - Api - alpha must belong to [0,1].')
        end
        @alpha = value
      end
      def setBeta(percentageOfTotalWeights, amountOfTimePoints)
        value = 1 - Math.exp((Math.log10(1 - percentageOfTotalWeights)) / amountOfTimePoints)
        if value < 0 || value > 1
          throw Exception.new('HoltWintersForecasting - Api - beta must belong to [0,1].')
        end
        @beta = value
      end
      def setGamma(percentageOfTotalWeights, amountOfTimePoints)
        value = 1 - Math.exp((Math.log10(1 - percentageOfTotalWeights)) / amountOfTimePoints)
        if value < 0 || value > 1
          throw Exception.new('HoltWintersForecasting - Api - beta must belong to [0,1].')
        end
        @gamma = value
      end
      def setTeta(value)
        if value.nil? || value < 2 || value > 3
          throw Exception.new('HoltWintersForecasting - Api - teta must belong to [2,3].')
        end
        @teta = value
      end
      def isAberrantBehavior(actualValue, confidenceBandUpperValue)
        # Is there aberrant behavior at moment T?
        # During "cold start" confidenceBandUpperValue might be nil, for the lack of prior observations.
        # We will return false in this case.
        if confidenceBandUpperValue
          return actualValue > confidenceBandUpperValue
        end
        return false
      end
      def getBaseline(actualValue, seasonalTrendAtPreviousSeason, previousBaseline, previousLinearTrend)
        # What is baseline at moment T?
        # Other terms for baseline: intercept, level.
        return @alpha*(actualValue-seasonalTrendAtPreviousSeason)+(1-@alpha)*(previousBaseline+previousLinearTrend)
      end
      def getConfidenceBandUpperValue(estimatedValue, weightedAvgAbsDeviationAtPreviousSeason)
        # What is upper value for confidence band at moment T+1?
        return estimatedValue+(@teta*weightedAvgAbsDeviationAtPreviousSeason)
      end
      def getEstimatedValue(baseline, linearTrend, seasonalTrendForNextStepAtPreviousSeason)
        return baseline+linearTrend+seasonalTrendForNextStepAtPreviousSeason
      end
      def getLinearTrend(baseline, previousBaseline, previousLinearTrend)
        # What is linear trend at moment T?
        # Other terms for linearTrend: slope
        return @beta*(baseline-previousBaseline)+((1-@beta)*previousLinearTrend)
      end
      def getSeasonalTrend(actualValue, baseline, seasonalTrendAtPreviousSeason)
        # What is seasonal trend at moment T?
        return @gamma*(actualValue-baseline)+((1-@gamma)*seasonalTrendAtPreviousSeason)
      end
      def getWeightedAvgAbsDeviation(actualValue, estimatedValue, weightedAvgAbsDeviationAtPreviousSeason)
        # What is weighted average absolute deviation at moment T?
        return @gamma*(actualValue-estimatedValue).abs()+((1-@gamma)*weightedAvgAbsDeviationAtPreviousSeason)
      end
    end # Api
  end # HoltWintersForecasting
end # Algorithms