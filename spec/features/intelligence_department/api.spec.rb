# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'IntelligenceApi', type: :feature do
  subject(:intelligence_api) { Departments::Intelligence::Api.instance }
  let(:legal_query) {
    Departments::Shared::IntelligenceQuery.new(
      IPAddr.new('79.181.31.4').to_i,
      Departments::Shared::IntelligenceFormat::ICMP_DOS_CYBER_REPORT
    )
  }
  let(:illegal_queries) {
    [
      nil,
      1,
      '2',
      {},
      []
    ]
  }
  let(:illegal_ips) {
    [nil, '1', -1, '1.3.4', {}, []]
  }
  let(:illegal_collect_formats) {
    [nil, '1', -1, 'something', {}, []]
  }

  it 'Throws an error when starting the intelligence gathering with an illegal query.' do
    illegal_queries.each do |query|
      expect {
        intelligence_api.start_intelligence_gathering(query)
      }.to raise_error(StandardError, /must be an instance of #{Departments::Shared::IntelligenceQuery.name}/)
    end
    illegal_ips.each do |ip|
      expect {
        intelligence_api.start_intelligence_gathering(Departments::Shared::IntelligenceQuery.new(
                                                        ip,
                                                        Departments::Shared::IntelligenceFormat::ICMP_DOS_CYBER_REPORT
                                                      ))
      }.to raise_error(StandardError, /must be a positive #{Integer.name}/)
    end
    illegal_collect_formats.each do |f|
      expect {
        intelligence_api.start_intelligence_gathering(Departments::Shared::IntelligenceQuery.new(
                                                        IPAddr.new('79.181.31.4').to_i,
                                                        f
                                                      ))
      }.to raise_error(StandardError, /must be one of #{Departments::Shared::IntelligenceFormat.name} formats/)
    end
  end

  it 'Throws an error when stopping the intelligence gathering with an illegal query.' do
    illegal_queries.each do |query|
      expect {
        intelligence_api.stop_intelligence_gathering(query)
      }.to raise_error(StandardError, /must be an instance of #{Departments::Shared::IntelligenceQuery.name}/)
    end
    illegal_ips.each do |ip|
      expect {
        intelligence_api.stop_intelligence_gathering(Departments::Shared::IntelligenceQuery.new(
                                                       ip,
                                                       Departments::Shared::IntelligenceFormat::ICMP_DOS_CYBER_REPORT
                                                     ))
      }.to raise_error(StandardError, /must be a positive #{Integer.name}/)
    end
    illegal_collect_formats.each do |f|
      expect {
        intelligence_api.stop_intelligence_gathering(Departments::Shared::IntelligenceQuery.new(
                                                       IPAddr.new('79.181.31.4').to_i,
                                                       f
                                                     ))
      }.to raise_error(StandardError, /must be one of #{Departments::Shared::IntelligenceFormat.name} formats/)
    end
  end

  it 'Throws an error checking out if a type of intelligence is still needed with illegal query.' do
    illegal_queries.each do |query|
      expect {
        intelligence_api.continue_collection?(query)
      }.to raise_error(StandardError, /must be an instance of #{Departments::Shared::IntelligenceQuery.name}/)
    end
    illegal_ips.each do |ip|
      expect {
        intelligence_api.continue_collection?(Departments::Shared::IntelligenceQuery.new(
                                                ip,
                                                Departments::Shared::IntelligenceFormat::ICMP_DOS_CYBER_REPORT
                                              ))
      }.to raise_error(StandardError, /must be a positive #{Integer.name}/)
    end
    illegal_collect_formats.each do |f|
      expect {
        intelligence_api.continue_collection?(Departments::Shared::IntelligenceQuery.new(
                                                IPAddr.new('79.181.31.4').to_i,
                                                f
                                              ))
      }.to raise_error(StandardError, /must be one of #{Departments::Shared::IntelligenceFormat.name} formats/)
    end
  end
end
