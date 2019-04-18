# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Workers - SQL Injection Report Producer', type: :feature do
  subject(:archive_api) { Departments::Archive::Api.instance }
  let(:legal_name) { 'Demo_1' }
  let(:legal_ip_address) { '79.181.31.4' }
  let(:friendly_resource) {
    archive_api.new_friendly_resource(legal_name, legal_ip_address)
  }
  let(:cyber_report_type) { Departments::Shared::AnalysisType::SQL_INJECTION_CYBER_REPORT }
  let(:sql_injection_positive_intelligence) {
    [
      { 'uris' => ['DROP DATABASE test;', '/DROP DATABASE test;/'] },
      { 'uris' => ['DROP DATABASE test;'] }
    ]
  }
  let(:sql_injection_negative_intelligence) {
    [
      { 'uris' => ['name=one;', '/1/'] },
      { 'uris' => ['DROP DATASE test;'] }
    ]
  }

  it 'Identifies SQL Injection when it is present' do
    archive_api.persist_friendly_resource(friendly_resource)
    sql_injection_positive_intelligence.each do |intelligence|
      Workers::Analysis::CodeInjection::Sql::CyberReportProducer.new.perform(
        friendly_resource.ip_address,
        cyber_report_type,
        intelligence,
        log: false
      )
    end
    expect(
      archive_api.cyber_reports_by_friendly_resource_ip_and_type(
        friendly_resource.ip_address,
        cyber_report_type,
        1,
        2
      ).size
    ).to eql(2)
  end

  it 'Does not identify SQL Injection when it is not present' do
    archive_api.persist_friendly_resource(friendly_resource)
    sql_injection_negative_intelligence.each do |intelligence|
      Workers::Analysis::CodeInjection::Sql::CyberReportProducer.new.perform(
        friendly_resource.ip_address,
        cyber_report_type,
        intelligence,
        log: false
      )
      expect(
        archive_api.cyber_reports_by_friendly_resource_ip_and_type(
          friendly_resource.ip_address,
          cyber_report_type,
          1,
          2
        ).size
      ).to eql(0)
    end
  end
end
