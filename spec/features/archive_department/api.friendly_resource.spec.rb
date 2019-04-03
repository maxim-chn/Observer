# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ArchiveApi - FriendlyResource model', type: :feature do
  subject(:archive_api) { Departments::Archive::Api.instance }
  let(:illegal_name_empty) { '' }
  let(:illegal_name_null) { nil }
  let(:legal_name) { 'Demo_1' }
  let(:legal_ip_address_str) { '79.181.31.4' }
  let(:legal_ip_address_int) { IPAddr.new('79.181.31.4').to_i }
  let(:illegal_ip_address_null) { nil }
  let(:illegal_ip_address_str) { '79.181.31' }
  let(:illegal_ip_address_int) { -1 }

  it 'Throws an error when illegal name' do
    expect {
      archive_api.new_friendly_resource(illegal_name_empty, legal_ip_address_str)
    }.to raise_error(StandardError)
    expect {
      archive_api.new_friendly_resource(illegal_name_null, legal_ip_address_str)
    }.to raise_error(StandardError)
  end

  it 'Throws an error when illegal ip address' do
    expect {
      archive_api.new_friendly_resource(legal_name, illegal_ip_address_null)
    }.to raise_error(StandardError)
    expect {
      archive_api.new_friendly_resource(legal_name, illegal_ip_address_str)
    }.to raise_error(StandardError)
    expect {
      archive_api.new_friendly_resource(legal_name, illegal_ip_address_int)
    }.to raise_error(StandardError)
  end

  let(:friendly_resource) {
    archive_api.new_friendly_resource(legal_name, legal_ip_address_str)
  }

  it 'Persists a friendly resource' do
    expect {
      archive_api.persist_friendly_resource(friendly_resource)
    }.to_not raise_error
  end

  it 'Retrieves a persisted friendly resource from the DB by ip' do
    archive_api.persist_friendly_resource(friendly_resource)
    expect(
      archive_api.friendly_resource_by_ip(legal_ip_address_int).inspect
    ).to eql(friendly_resource.inspect)
  end

  it 'Retrieves a persisted friendly resource from the DB by id' do
    archive_api.persist_friendly_resource(friendly_resource)
    id = archive_api.friendly_resource_by_ip(legal_ip_address_int).id
    expect(
      archive_api.friendly_resource_by_id(id).inspect
    ).to eql(friendly_resource.inspect)
  end

  it 'Throws an error when retrieving friendly resource from the DB by non-integer ip' do
    archive_api.persist_friendly_resource(friendly_resource)
    expect {
      archive_api.friendly_resource_by_ip(legal_ip_address_str)
    }.to raise_error(StandardError)
  end

  let(:friendly_resource_hash) {
    { 'name' => legal_name, 'ip_address' => legal_ip_address_str }
  }

  it 'Creates friendly resource object from hash' do
    expect(
      archive_api.new_friendly_resource_from_hash(friendly_resource_hash).class.name
    ).to eql(FriendlyResource.name)
  end

  it 'Paginates persisted friendly resources in the DB' do
    friendly_resources_data = [
      { 'name' => 'Demo_2', 'ip_address' => '79.181.31.4' },
      { 'name' => 'Demo_3', 'ip_address' => '79.181.31.5' },
      { 'name' => 'Demo_4', 'ip_address' => '79.181.31.6' }
    ]
    friendly_resources_data.each do |f|
      archive_api.persist_friendly_resource(
        archive_api.new_friendly_resource_from_hash(f)
      )
    end
    expect(
      archive_api.all_friendly_resources(1, 1).size
    ).to eql(1)
    expect(
      archive_api.all_friendly_resources(2, 1).size
    ).to eql(1)
    expect(
      archive_api.all_friendly_resources(3, 1).size
    ).to eql(1)
    expect(
      archive_api.all_friendly_resources(1, 3).size
    ).to eql(3)
  end

  let(:icmp_dos_cyber_report_min_seasonal_index) {
    Algorithms::HoltWintersForecasting::Api.instance.min_seasonal_index(
      Algorithms::HoltWintersForecasting::ICMP_FLOOD
    )
  }

  it 'Retrieves a persisted friendly resource from the DB by a cyber report' do
    archive_api.persist_friendly_resource(friendly_resource)
    cyber_report = archive_api.new_cyber_report_object_for_friendly_resource(
      friendly_resource.ip_address,
      Departments::Shared::AnalysisType::ICMP_DOS_CYBER_REPORT,
      seasonal_index: icmp_dos_cyber_report_min_seasonal_index
    )
    archive_api.persist_cyber_report(cyber_report)
    expect(
      archive_api.friendly_resource_by_cyber_report(cyber_report).inspect
    ).to eql(friendly_resource.inspect)
  end
end
