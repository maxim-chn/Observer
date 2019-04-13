# frozen_string_literal: true

require 'rails_helper'
RSpec.describe 'ArchiveApi - CyberReport model.', type: :feature do
  subject(:archive_api) { Departments::Archive::Api.instance }
  let(:legal_cyber_report_types) {
    [
      Departments::Shared::AnalysisType::ICMP_DOS_CYBER_REPORT,
      Departments::Shared::AnalysisType::SQL_INJECTION_CYBER_REPORT
    ]
  }
  let(:legal_page) { 1 }
  let(:legal_page_size) { 1 }
  let(:legal_ip_address) { '79.181.31.4' }
  let(:legal_cyber_report_id) { 1 }
  let(:legal_seasonal_index) { 0 }
  let(:legal_opts) {
    { 'seasonal_index' => legal_seasonal_index }
  }
  let(:legal_sql_injection) { 'DROP DATABASE users;' }
  let(:illegal_ip_addresses) {
    [nil, '1', '1.3.4', -1]
  }
  let(:illegal_cyber_report_types) {
    [nil, 1, '12']
  }
  let(:illegal_pages) {
    [nil, '1', 0, -1]
  }
  let(:illegal_page_sizes) {
    [nil, '1', 0, -1]
  }
  let(:illegal_cyber_report_ids) {
    [nil, '1']
  }
  let(:illegal_opts) {
    [nil, { seasonal_index: legal_seasonal_index }, { 'seasonal' => legal_seasonal_index }, { 'seasonal_index' => -1 }]
  }
  let(:illegal_cyber_reports) {
    [nil, 1, '2']
  }

  it 'Throws an error when calling for persisted cyber reports amount with an illegal ip address.' do
    illegal_ip_addresses.each do |ip|
      expect {
        archive_api.cyber_reports_count(ip, legal_cyber_report_types[0])
      }.to raise_error(StandardError)
    end
  end

  it 'Throws an error when calling for persisted cyber reports amount with an illegal cyber report type.' do
    illegal_cyber_report_types.each do |type|
      expect {
        archive_api.cyber_reports_count(legal_ip_address, type)
      }.to raise_error(StandardError)
    end
  end

  it 'Retrieves the amount of the persisted cyber reports by an ip and a report type.' do
    friendly_resource = Departments::Archive::Api.instance.new_friendly_resource(
      'demo_1',
      legal_ip_address
    )
    friendly_resource.save
    legal_cyber_report_types.each do |type|
      (0..5).each do |n|
        case type
        when Departments::Shared::AnalysisType::ICMP_DOS_CYBER_REPORT
          next_cyber_report = Departments::Archive::Api.instance.new_cyber_report_object_for_friendly_resource(
            friendly_resource.ip_address,
            type,
            'seasonal_index' => n
          )
        when Departments::Shared::AnalysisType::SQL_INJECTION_CYBER_REPORT
          next_cyber_report = Departments::Archive::Api.instance.new_cyber_report_object_for_friendly_resource(
            friendly_resource.ip_address,
            type
          )
        end
        next_cyber_report.save
      end
      expect(
        archive_api.cyber_reports_count(
          friendly_resource.ip_address,
          type
        )
      ).to eql(6)
    end
  end

  it 'Throws an error when paginating over the persisted cyber reports with an illegal ip address.' do
    illegal_ip_addresses.each do |ip|
      expect {
        archive_api.cyber_reports_by_friendly_resource_ip_and_type(
          ip,
          legal_cyber_report_types[0],
          legal_page,
          legal_page_size
        )
      }.to raise_error(StandardError)
    end
  end

  it 'Throws an error when paginating over the persisted cyber reports with an illegal cyber report type.' do
    illegal_cyber_report_types.each do |type|
      expect {
        archive_api.cyber_reports_by_friendly_resource_ip_and_type(
          legal_ip_address,
          type,
          legal_page,
          legal_page_size
        )
      }.to raise_error(StandardError)
    end
  end

  it 'Throws an error when paginating over the persisted cyber reports with an illegal page.' do
    illegal_pages.each do |page|
      expect {
        archive_api.cyber_reports_by_friendly_resource_ip_and_type(
          legal_ip_address,
          legal_cyber_report_types[0],
          page,
          legal_page_size
        )
      }.to raise_error(StandardError)
    end
  end

  it 'Throws an error when paginating over the persisted cyber reports with an illegal page size.' do
    illegal_page_sizes.each do |size|
      expect {
        archive_api.cyber_reports_by_friendly_resource_ip_and_type(
          legal_ip_address,
          legal_cyber_report_types[0],
          legal_page,
          size
        )
      }.to raise_error(StandardError)
    end
  end

  it 'Paginates over the persisted cyber reports by an ip and a report type.' do
    friendly_resource = Departments::Archive::Api.instance.new_friendly_resource(
      'demo_1',
      legal_ip_address
    )
    friendly_resource.save
    legal_cyber_report_types.each do |type|
      (0..5).each do |n|
        case type
        when Departments::Shared::AnalysisType::ICMP_DOS_CYBER_REPORT
          next_cyber_report = Departments::Archive::Api.instance.new_cyber_report_object_for_friendly_resource(
            friendly_resource.ip_address,
            type,
            'seasonal_index' => n
          )
        when Departments::Shared::AnalysisType::SQL_INJECTION_CYBER_REPORT
          next_cyber_report = Departments::Archive::Api.instance.new_cyber_report_object_for_friendly_resource(
            friendly_resource.ip_address,
            type
          )
        end
        next_cyber_report.save
      end
      expect(
        archive_api.cyber_reports_by_friendly_resource_ip_and_type(
          friendly_resource.ip_address,
          type,
          legal_page,
          legal_page_size
        ).size
      ).to eql(legal_page_size)
      expect(
        archive_api.cyber_reports_by_friendly_resource_ip_and_type(
          friendly_resource.ip_address,
          type,
          3,
          3
        ).size
      ).to eql(0)
      expect(
        archive_api.cyber_reports_by_friendly_resource_ip_and_type(
          friendly_resource.ip_address,
          type,
          2,
          3
        ).size
      ).to eql(3)
    end
  end

  it 'Throws an error when retrieving a persisted cyber report by an illegal id.' do
    illegal_cyber_report_ids.each do |id|
      expect {
        archive_api.cyber_report_by_id_and_type(id, legal_cyber_report_types[0])
      }.to raise_error(StandardError)
    end
  end

  it 'Throws an error when retrieving a persisted cyber report by an illegal report type.' do
    illegal_cyber_report_types.each do |type|
      expect {
        archive_api.cyber_report_by_id_and_type(legal_cyber_report_id, type)
      }.to raise_error(StandardError)
      expect {
        archive_api.cyber_report_by_friendly_resource_ip_and_type_and_custom_attr(
          legal_ip,
          type,
          legal_opts
        )
      }.to raise_error(StandardError)
    end
  end

  it 'Retrieves a persisted cyber report by its id and type.' do
    friendly_resource = Departments::Archive::Api.instance.new_friendly_resource(
      'demo_1',
      legal_ip_address
    )
    friendly_resource.save
    legal_cyber_report_types.each do |type|
      case type
      when Departments::Shared::AnalysisType::ICMP_DOS_CYBER_REPORT
        cyber_report = Departments::Archive::Api.instance.new_cyber_report_object_for_friendly_resource(
          friendly_resource.ip_address,
          type,
          'seasonal_index' => legal_seasonal_index
        )
      when Departments::Shared::AnalysisType::SQL_INJECTION_CYBER_REPORT
        cyber_report = Departments::Archive::Api.instance.new_cyber_report_object_for_friendly_resource(
          friendly_resource.ip_address,
          type
        )
        cyber_report.reason = legal_sql_injection
      end
      cyber_report.save
      expect(
        archive_api.cyber_report_by_id_and_type(cyber_report.id, type).inspect
      ).to eql(cyber_report.inspect)
    end
  end

  it 'Throws an error when retrieving a persisted cyber report by an illegal ip.' do
    illegal_ip_addresses.each do |ip|
      expect {
        archive_api.cyber_report_by_friendly_resource_ip_and_type_and_custom_attr(
          ip,
          legal_cyber_report_types[0],
          legal_opts
        )
      }.to raise_error(StandardError)
    end
  end

  it 'Throws an error when retrieving a persisted cyber report by the illegal custom attributes.' do
    illegal_opts.each do |opt|
      expect {
        archive_api.cyber_report_by_friendly_resource_ip_and_type_and_custom_attr(
          legal_ip,
          legal_cyber_report_types[0],
          opt
        )
      }.to raise_error(StandardError)
    end
  end

  it 'Retrieves a persisted cyber report by an ip, report type and custom attributes.' do
    friendly_resource = Departments::Archive::Api.instance.new_friendly_resource(
      'demo_1',
      legal_ip_address
    )
    friendly_resource.save
    cyber_report = Departments::Archive::Api.instance.new_cyber_report_object_for_friendly_resource(
      friendly_resource.ip_address,
      legal_cyber_report_types[0],
      'seasonal_index' => legal_seasonal_index
    )
    cyber_report.save
    expect(
      archive_api.cyber_report_by_friendly_resource_ip_and_type_and_custom_attr(
        friendly_resource.ip_address,
        legal_cyber_report_types[0],
        legal_opts
      ).inspect
    ).to eql(cyber_report.inspect)
  end

  it 'Throws an error when creating a new cyber report object with an illegal ip.' do
    illegal_ip_addresses.each do |ip|
      expect {
        archive_api.new_cyber_report_object_for_friendly_resource(
          ip,
          legal_cyber_report_types[0],
          legal_opts
        )
      }.to raise_error(StandardError)
    end
  end

  it 'Throws an error when creating a new cyber report object with an illegal report type.' do
    illegal_cyber_report_types.each do |type|
      expect {
        archive_api.new_cyber_report_object_for_friendly_resource(
          legal_ip,
          type,
          legal_opts
        )
      }.to raise_error StandardError
    end
  end

  it 'Creates a new cyber report object by an ip, report type and custom attributes.' do
    friendly_resource = Departments::Archive::Api.instance.new_friendly_resource(
      'demo_1',
      legal_ip_address
    )
    friendly_resource.save
    legal_cyber_report_types.each do |type|
      case type
      when Departments::Shared::AnalysisType::ICMP_DOS_CYBER_REPORT
        expect(
          archive_api.new_cyber_report_object_for_friendly_resource(
            friendly_resource.ip_address,
            type,
            legal_opts
          ).class < CyberReport
        ).to be_truthy
      when Departments::Shared::AnalysisType::SQL_INJECTION_CYBER_REPORT
        expect(
          archive_api.new_cyber_report_object_for_friendly_resource(
            friendly_resource.ip_address,
            type
          ).class < CyberReport
        ).to be_truthy
      end
    end
  end

  it 'Throws an error when trying to persist an illegal cyber report.' do
    illegal_cyber_reports.each do |report|
      expect {
        archive_api.persist_cyber_report(report)
      }.to raise_error(StandardError)
    end
  end

  it 'Persists a cyber report.' do
    friendly_resource = Departments::Archive::Api.instance.new_friendly_resource(
      'demo_1',
      legal_ip_address
    )
    friendly_resource.save
    legal_cyber_report_types.each do |type|
      case type
      when Departments::Shared::AnalysisType::ICMP_DOS_CYBER_REPORT
        cyber_report = Departments::Archive::Api.instance.new_cyber_report_object_for_friendly_resource(
          friendly_resource.ip_address,
          type,
          'seasonal_index' => legal_seasonal_index
        )
      when Departments::Shared::AnalysisType::SQL_INJECTION_CYBER_REPORT
        cyber_report = Departments::Archive::Api.instance.new_cyber_report_object_for_friendly_resource(
          friendly_resource.ip_address,
          type
        )
      end
      expect {
        cyber_report.save
      }.to_not raise_error
    end
  end

  it 'Retrieves the cyber report types.' do
    expect(
      Departments::Shared::AnalysisType.formats.class
    ).to eql(Array)
    expect(
      Departments::Shared::AnalysisType.formats.size == 2
    ).to be_truthy
  end
end
