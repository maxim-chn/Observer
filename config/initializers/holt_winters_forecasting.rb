require("#{Rails.root}/lib/algorithms/holt_winters_forecasting/api.rb")
# We would like our algorithm in a lib to be unaware of inside logic of an app.
# Thus, intialization of necessary constants, i.e. smoothing constants is done here,
# which is like a "middle ground" where independent parts are aware of themselves for the first time.
holtWintersApi = Algorithms::HoltWintersForecasting::Api.instance()
holtWintersApi.setHourDurationInMinutes(Dos::DosReport::MINUTES_IN_AN_HOUR)
holtWintersApi.setMinuteDurationInSeconds(Dos::DosReport::SECONDS_IN_A_MINUTE)
holtWintersApi.setIntervalBetweenCollectionsInSeconds(Dos::DosReport::INTERVAL_BETWEEN_COLLECTIONS_IN_SECONDS)
holtWintersApi.setMinSeasonalIndex(Dos::DosReport::FIRST_SEASONAL_INDEX)
holtWintersApi.setMaxSeasonalIndex(Dos::DosReport::LAST_SEASONAL_INDEX)
# Alpha denotes baseline smoothing.
# A guess : last hour of observations should have 75% of "importance".
holtWintersApi.setAlpha(
  0.75, Dos::DosReport::MINUTES_IN_AN_HOUR * Dos::DosReport::SECONDS_IN_A_MINUTE / Dos::DosReport::INTERVAL_BETWEEN_COLLECTIONS_IN_SECONDS
)
# Beta denotes linear trend smoothing longer than 1 seasonal cycle.
# Last day observations should not have more than 50% of "importance".
holtWintersApi.setBeta(
  0.5, Dos::DosReport::SEASON_DURATION_IN_SECONDS / Dos::DosReport::INTERVAL_BETWEEN_COLLECTIONS_IN_SECONDS
)
# Gamma denotes seasonal smoothing.
# A guess : last 7 days of observations should not have more than 50% of "importance".
holtWintersApi.setGamma(
  0.5, Dos::DosReport::DAYS_IN_A_WEEK * Dos::DosReport::SEASON_DURATION_IN_SECONDS / Dos::DosReport::INTERVAL_BETWEEN_COLLECTIONS_IN_SECONDS
)
# Teta denotes scaling factor for confidence bands.
# Value close to 2 is chosen when missing true positive is more harmful than getting a false positive.
# Value close to 3 is chosen when getting false positive is more harmful than missing true positive.
holtWintersApi.setTeta(2)