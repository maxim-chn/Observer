# frozen_string_literal: true

require(Rails.root.join('lib', 'algorithms', 'holt_winters_forecasting', 'api.rb'))
##
# Our algorithm is in a lib - unaware of inside logic of an app.
# Hence, intialization of necessary constants, i.e. smoothing constants, is done here.
# This is like a "middle ground" where independent parts are aware of themselves for the first time.
holt_winters_api = Algorithms::HoltWintersForecasting::Api.instance
holt_winters_api.setHourDurationInMinutes(Dos::DosReport::MINUTES_IN_AN_HOUR)
holt_winters_api.setMinuteDurationInSeconds(Dos::DosReport::SECONDS_IN_A_MINUTE)
holt_winters_api.setIntervalBetweenCollectionsInSeconds(Dos::DosReport::INTERVAL_BETWEEN_COLLECTIONS_IN_SECONDS)
holt_winters_api.setMinSeasonalIndex(Dos::DosReport::FIRST_SEASONAL_INDEX)
holt_winters_api.setMaxSeasonalIndex(Dos::DosReport::LAST_SEASONAL_INDEX)
# Alpha denotes baseline smoothing.
# A guess : last hour of observations should have 75% of "importance".
mins_in_an_hour = Dos::DosReport::MINUTES_IN_AN_HOUR
secs_in_a_min = Dos::DosReport::SECONDS_IN_A_MINUTE
interval_between_collections = Dos::DosReport::INTERVAL_BETWEEN_COLLECTIONS_IN_SECONDS
season_duration_in_secs = Dos::DosReport::SEASON_DURATION_IN_SECONDS
days_in_a_week = Dos::DosReport::DAYS_IN_A_WEEK
holt_winters_api.setAlpha(0.75, mins_in_an_hour * secs_in_a_min / interval_between_collections)
# Beta denotes linear trend smoothing longer than 1 seasonal cycle.
# Last day observations should not have more than 50% of "importance".
holt_winters_api.setBeta(0.5, season_duration_in_secs / interval_between_collections)
# Gamma denotes seasonal smoothing.
# A guess : last 7 days of observations should not have more than 50% of "importance".
holt_winters_api.setGamma(0.5, days_in_a_week * season_duration_in_secs / interval_between_collections)
# Teta denotes scaling factor for confidence bands.
# Value close to 2 is chosen when missing true positive is more harmful than getting a false positive.
# Value close to 3 is chosen when getting false positive is more harmful than missing true positive.
holt_winters_api.setTeta(2)
