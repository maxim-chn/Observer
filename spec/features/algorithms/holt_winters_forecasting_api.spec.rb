# frozen_string_literal: true

require 'rails_helper'
RSpec.describe 'HoltWintersForecastingApi', type: :feature do
  let(:hw_forecasting_api) { Algorithms::HoltWintersForecasting::Api.instance }
  let(:icmp_flood_analysis) { Algorithms::HoltWintersForecasting::ICMP_FLOOD }
  let(:min_seasonal_index) { hw_forecasting_api.min_seasonal_index(icmp_flood_analysis) }
  let(:max_seasonal_index) { hw_forecasting_api.max_seasonal_index(icmp_flood_analysis) }
  let(:legal_duration_of_time_unit_in_seconds) { 10 }
  let(:legal_weights_percentage_value) { 0.9 }
  let(:legal_collections_count) { 10 }
  let(:legal_teta_value) { 2 }
  let(:illegal_duration_of_time_unit_in_seconds) {
    [nil, -1, '1', {}, []]
  }
  let(:illegal_weights_percentage_values) {
    [nil, -1, '1', 1.1, 2, {}, []]
  }
  let(:illegal_collections_counts) {
    [nil, -1, '1', 1.1, {}, []]
  }
  let(:illegal_teta_values) {
    [nil, -1, '1', 1.1, 1, {}, []]
  }
  it 'Throws an error when setting the duration of a time unit in an algorithm with an illegal seconds value.' do
    illegal_duration_of_time_unit_in_seconds.each do |sec|
      expect {
        hw_forecasting_api.time_unit_in_seconds(icmp_flood_analysis, sec)
      }.to raise_error(StandardError, /is not a positive #{Integer.name}/)
    end
  end
  it 'Updates the duration of a time unit in an algorithm in seconds.' do
    expect {
      hw_forecasting_api.time_unit_in_seconds(icmp_flood_analysis, legal_duration_of_time_unit_in_seconds)
    }.not_to raise_error
  end
  it 'Throws an error when updating alpha smoothing constant with illegal weights percentage value.' do
    illegal_weights_percentage_values.each do |value|
      expect {
        hw_forecasting_api.alpha(value, legal_collections_count)
      }.to raise_error(StandardError, /must be a #{Float.name} in the range \[0.0, 1.0\]/)
    end
  end
  it 'Throws an error when updating alpha smoothing constant with illegal collections count value.' do
    illegal_collections_counts.each do |count|
      expect {
        hw_forecasting_api.alpha(legal_weights_percentage_value, count)
      }.to raise_error(StandardError, /is not a positive #{Integer.name}/)
    end
  end
  it 'Updates the alpha smoothing constant with legal weights percentage and collections count.' do
    expect {
      hw_forecasting_api.alpha(legal_weights_percentage_value, legal_collections_count)
    }.to_not raise_error
  end
  it 'Throws an error when updating beta smoothing constant with illegal weights percentage value.' do
    illegal_weights_percentage_values.each do |value|
      expect {
        hw_forecasting_api.beta(value, legal_collections_count)
      }.to raise_error(StandardError, /must be a #{Float.name} in the range \[0.0, 1.0\]/)
    end
  end
  it 'Throws an error when updating beta smoothing constant with illegal collections count value.' do
    illegal_collections_counts.each do |count|
      expect {
        hw_forecasting_api.beta(legal_weights_percentage_value, count)
      }.to raise_error(StandardError, /is not a positive #{Integer.name}/)
    end
  end
  it 'Updates the beta smoothing constant with legal weights percentage and collections count.' do
    expect {
      hw_forecasting_api.beta(legal_weights_percentage_value, legal_collections_count)
    }.to_not raise_error
  end
  it 'Throws an error when updating gamma smoothing constant with illegal weights percentage value.' do
    illegal_weights_percentage_values.each do |value|
      expect {
        hw_forecasting_api.gamma(value, legal_collections_count)
      }.to raise_error(StandardError, /must be a #{Float.name} in the range \[0.0, 1.0\]/)
    end
  end
  it 'Throws an error when updating gamma smoothing constant with illegal collections count value.' do
    illegal_collections_counts.each do |count|
      expect {
        hw_forecasting_api.gamma(legal_weights_percentage_value, count)
      }.to raise_error(StandardError, /is not a positive #{Integer.name}/)
    end
  end
  it 'Updates the gamma smoothing constant with legal weights percentage and collections count.' do
    expect {
      hw_forecasting_api.gamma(legal_weights_percentage_value, legal_collections_count)
    }.to_not raise_error
  end
  it 'Throws an error when updating teta smoothing constant with illegal values.' do
    illegal_teta_values.each do |value|
      expect {
        hw_forecasting_api.teta(value)
      }.to raise_error(StandardError, /must belong to \[/)
    end
  end
  it 'Updates the teta smoothing constant.' do
    expect {
      hw_forecasting_api.teta(legal_teta_value)
    }.to_not raise_error
  end
  it 'Retrieves the current seasonal index' do
    expect(hw_forecasting_api.seasonal_index(icmp_flood_analysis)).to be_between(min_seasonal_index, max_seasonal_index)
  end
  it 'Retrieves the next seasonal index' do
    expect(hw_forecasting_api.next_seasonal_index(icmp_flood_analysis, max_seasonal_index)).to eql(min_seasonal_index)
  end
  it 'Retrieves the previous seasonal index' do
    expect(hw_forecasting_api.prev_seasonal_index(icmp_flood_analysis, min_seasonal_index)).to eql(max_seasonal_index)
  end
  let(:actual_value) { 1000 }
  let(:confidence_band_upper_value) { 200.3 }
  let(:baseline) { 100.2 }
  let(:linear_trend) { 5.2 }
  let(:seasonal_trend) { 3.3 }
  let(:estimated_value) { 232.2 }
  let(:actual_value_illegal) { -1 }
  let(:weighted_avg_abs_deviation) { 2.2 }
  let(:confidence_band_upper_value_illegal) { -1 }
  let(:baseline_illegal) { -1.2 }
  let(:linear_trend_illegal) { -1.0 }
  let(:seasonal_trend_illegal) { -22.3 }
  let(:estimated_value_illegal) { -12.9 }
  let(:weighted_avg_abs_deviation_illegal) { -2.2 }
  it 'Throws an error when actual value is illegal' do
    expect {
      hw_forecasting_api.aberrant_behavior(actual_value_illegal, confidence_band_upper_value)
    }.to raise_error(StandardError)
    expect {
      hw_forecasting_api.aberrant_behavior(confidence_band_upper_value, confidence_band_upper_value)
    }.to raise_error(StandardError)
    expect {
      hw_forecasting_api.baseline(actual_value_illegal, seasonal_trend, baseline, linear_trend)
    }.to raise_error(StandardError)
    expect {
      hw_forecasting_api.seasonal_trend(actual_value_illegal, baseline, seasonal_trend)
    }.to raise_error(StandardError)
    expect {
      hw_forecasting_api.weighted_avg_abs_deviation(
        actual_value_illegal,
        estimated_value,
        weighted_avg_abs_deviation
      )
    }.to raise_error(StandardError)
  end
  it 'Throws an error when confidence_band_upper value is illegal' do
    expect {
      hw_forecasting_api.aberrant_behavior(actual_value, confidence_band_upper_value_illegal)
    }.to raise_error(StandardError)
  end
  it 'Throws an error when baseline value is illegal' do
    expect {
      hw_forecasting_api.estimated_value(baseline_illegal, linear_trend, seasonal_trend)
    }.to raise_error(StandardError)
    expect {
      hw_forecasting_api.baseline(actual_value, seasonal_trend, baseline_illegal, linear_trend)
    }.to raise_error(StandardError)
    expect {
      hw_forecasting_api.linear_trend(baseline_illegal, baseline + 1, linear_trend + 1)
    }.to raise_error(StandardError)
    expect {
      hw_forecasting_api.linear_trend(baseline, baseline_illegal, linear_trend + 1)
    }.to raise_error(StandardError)
    expect {
      hw_forecasting_api.seasonal_trend(actual_value, baseline_illegal, seasonal_trend)
    }.to raise_error(StandardError)
  end
  it 'Throws an error when seasonal_trend value is illegal' do
    expect {
      hw_forecasting_api.estimated_value(baseline, linear_trend, seasonal_trend_illegal)
    }.to raise_error(StandardError)
    expect {
      hw_forecasting_api.baseline(actual_value, seasonal_trend_illegal, baseline, linear_trend)
    }.to raise_error(StandardError)
    expect {
      hw_forecasting_api.seasonal_trend(actual_value_illegal, baseline, seasonal_trend_illegal)
    }.to raise_error(StandardError)
  end
  it 'Throws an error when linear_trend value is illegal' do
    expect {
      hw_forecasting_api.estimated_value(baseline_illegal, linear_trend_illegal, seasonal_trend)
    }.to raise_error(StandardError)
    expect {
      hw_forecasting_api.baseline(actual_value, seasonal_trend, baseline, linear_trend_illegal)
    }.to raise_error(StandardError)
    expect {
      hw_forecasting_api.linear_trend(baseline, baseline + 1, linear_trend_illegal)
    }.to raise_error(StandardError)
  end
  it 'Throws an error when estimated value is illegal' do
    expect {
      hw_forecasting_api.confidence_band_upper_value(estimated_value_illegal, weighted_avg_abs_deviation)
    }.to raise_error(StandardError)
    expect {
      hw_forecasting_api.weighted_avg_abs_deviation(
        actual_value,
        estimated_value_illegal,
        weighted_avg_abs_deviation
      )
    }.to raise_error(StandardError)
  end
  it 'Throws an error when weighted average absolute deviation value is illegal' do
    expect {
      hw_forecasting_api.confidence_band_upper_value(estimated_value, weighted_avg_abs_deviation_illegal)
    }.to raise_error(StandardError)
    expect {
      hw_forecasting_api.weighted_avg_abs_deviation(
        actual_value,
        estimated_value,
        weighted_avg_abs_deviation_illegal
      )
    }.to raise_error(StandardError)
  end
  it 'Identifies the aberrant behavior' do
    expect(
      hw_forecasting_api.aberrant_behavior(actual_value, confidence_band_upper_value)
    ).to be true
  end
  it 'Identifies the none aberrant behavior' do
    expect(
      hw_forecasting_api.aberrant_behavior((confidence_band_upper_value - 1).to_i, confidence_band_upper_value)
    ).to be false
    expect(
      hw_forecasting_api.aberrant_behavior(actual_value, nil)
    ).to be false
  end
  it 'Calculates the estimated value' do
    expect(
      hw_forecasting_api.estimated_value(baseline, linear_trend, seasonal_trend)
    ).to be > 0
    expect(
      hw_forecasting_api.estimated_value(baseline, linear_trend, nil)
    ).to be > 0
  end
  it 'Calculates the baseline value' do
    expect(
      hw_forecasting_api.baseline(actual_value, seasonal_trend, baseline, linear_trend)
    ).to be > 0
    expect(
      hw_forecasting_api.baseline(actual_value, nil, baseline, linear_trend)
    ).to be > 0
    expect(
      hw_forecasting_api.baseline(actual_value, seasonal_trend, nil, linear_trend)
    ).to be > 0
    expect(
      hw_forecasting_api.baseline(actual_value, seasonal_trend, nil, nil)
    ).to be > 0
    expect(
      hw_forecasting_api.baseline(actual_value, nil, nil, nil)
    ).to be > 0
  end
  it 'Calculates the confidence band upper value' do
    expect(
      hw_forecasting_api.confidence_band_upper_value(estimated_value, weighted_avg_abs_deviation)
    ).to be > 0
    expect(
      hw_forecasting_api.confidence_band_upper_value(estimated_value, nil)
    ).to be > 0
  end
  it 'Calculates the linear_trend value' do
    expect(
      hw_forecasting_api.linear_trend(baseline, baseline + 1, linear_trend + 1)
    ).to be > 0
    expect(
      hw_forecasting_api.linear_trend(baseline, nil, nil)
    ).to be > 0
  end
  it 'Calculates the seasonal_trend value' do
    expect(
      hw_forecasting_api.seasonal_trend(actual_value, baseline, seasonal_trend)
    ).to be > 0
    expect(
      hw_forecasting_api.seasonal_trend(actual_value, baseline, nil)
    ).to be > 0
    expect(
      hw_forecasting_api.seasonal_trend(actual_value, nil, seasonal_trend)
    ).to be > 0
    expect(
      hw_forecasting_api.seasonal_trend(actual_value, nil, nil)
    ).to be > 0
  end
  it 'Calculates the weighted_average_absolute_deviation value' do
    expect(
      hw_forecasting_api.weighted_avg_abs_deviation(
        actual_value,
        estimated_value,
        weighted_avg_abs_deviation
      )
    ).to be > 0
    expect(
      hw_forecasting_api.weighted_avg_abs_deviation(
        actual_value,
        estimated_value,
        nil
      )
    ).to be > 0
    expect(
      hw_forecasting_api.weighted_avg_abs_deviation(
        actual_value,
        nil,
        weighted_avg_abs_deviation
      )
    ).to be > 0
    expect(
      hw_forecasting_api.weighted_avg_abs_deviation(
        actual_value,
        nil,
        nil
      )
    ).to be > 0
  end
end
