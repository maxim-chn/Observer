# frozen_string_literal: true

require 'rails_helper'
RSpec.describe 'HoltWintersForecastingApi', type: :feature do
  let(:hw_forecasting_api) { Algorithms::HoltWintersForecasting::Api.instance }
  let(:icmp_flood_analysis) { Algorithms::HoltWintersForecasting::ICMP_FLOOD }
  it 'Throws error when seconds value is illegal' do
    expect {
      hw_forecasting_api.time_unit_in_seconds(icmp_flood_analysis, -1)
    }.to raise_error(StandardError)
  end
  it 'Updates duration of time unit in seconds' do
    expect {
      hw_forecasting_api.time_unit_in_seconds(icmp_flood_analysis, 10)
    }.not_to raise_error
  end
  it 'Throws error when alpha value is illegal' do
    expect {
      hw_forecasting_api.alpha(200, -1)
    }.to raise_error(StandardError)
  end
  it 'Throws error when beta value is illegal' do
    expect {
      hw_forecasting_api.beta(0.9, -1)
    }.to raise_error(StandardError)
  end
  it 'Throws error when gamma value is illegal' do
    expect {
      hw_forecasting_api.gamma(2, 10)
    }.to raise_error(StandardError)
  end
  it 'Throws error when teta value is illegal' do
    expect {
      hw_forecasting_api.teta(0.1)
    }.to raise_error(StandardError)
  end
  let(:min_seasonal_index) { hw_forecasting_api.min_seasonal_index(icmp_flood_analysis) }
  let(:max_seasonal_index) { hw_forecasting_api.max_seasonal_index(icmp_flood_analysis) }
  it 'Retrieves current seasonal index' do
    expect(hw_forecasting_api.seasonal_index(icmp_flood_analysis)).to be_between(min_seasonal_index, max_seasonal_index)
  end
  it 'Retrieves next seasonal index' do
    expect(hw_forecasting_api.next_seasonal_index(icmp_flood_analysis, max_seasonal_index)).to eql(min_seasonal_index)
  end
  it 'Retrieves previous seasonal index' do
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
  it 'Throws error when actual value is illegal' do
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
  it 'Throws error when confidence_band_upper value is illegal' do
    expect {
      hw_forecasting_api.aberrant_behavior(actual_value, confidence_band_upper_value_illegal)
    }.to raise_error(StandardError)
  end
  it 'Throws error when baseline value is illegal' do
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
  it 'Throws error when seasonal_trend value is illegal' do
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
  it 'Throws error when linear_trend value is illegal' do
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
  it 'Throws error when estimated value is illegal' do
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
  it 'Throws error when weighted average absolute deviation value is illegal' do
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
  it 'Identifies aberrant behavior' do
    expect(
      hw_forecasting_api.aberrant_behavior(actual_value, confidence_band_upper_value)
    ).to be true
  end
  it 'Identifies none aberrant behavior' do
    expect(
      hw_forecasting_api.aberrant_behavior((confidence_band_upper_value - 1).to_i, confidence_band_upper_value)
    ).to be false
    expect(
      hw_forecasting_api.aberrant_behavior(actual_value, nil)
    ).to be false
  end
  it 'Calculates estimated value' do
    expect(
      hw_forecasting_api.estimated_value(baseline, linear_trend, seasonal_trend)
    ).to be > 0
    expect(
      hw_forecasting_api.estimated_value(baseline, linear_trend, nil)
    ).to be > 0
  end
  it 'Calculates baseline value' do
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
  it 'Calculates confidence band upper value' do
    expect(
      hw_forecasting_api.confidence_band_upper_value(estimated_value, weighted_avg_abs_deviation)
    ).to be > 0
    expect(
      hw_forecasting_api.confidence_band_upper_value(estimated_value, nil)
    ).to be > 0
  end
  it 'Calculates linear_trend value' do
    expect(
      hw_forecasting_api.linear_trend(baseline, baseline + 1, linear_trend + 1)
    ).to be > 0
    expect(
      hw_forecasting_api.linear_trend(baseline, nil, nil)
    ).to be > 0
  end
  it 'Calculates seasonal_trend value' do
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
  it 'Calculates weighted_average_absolute_deviation value' do
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
