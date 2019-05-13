# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ArchiveApi - FriendlyResource model.', type: :feature do
  subject(:archive_api) { Departments::Archive::Api.instance }
  let(:legal_name) { 'Demo_1' }
  let(:legal_ip_address) { '79.181.31.4' }
  let(:friendly_resource) {
    archive_api.new_friendly_resource(legal_name, legal_ip_address)
  }
  let(:friendly_resource_hash) {
    { 'name' => legal_name, 'ip_address' => legal_ip_address }
  }
  let(:icmp_dos_cyber_report_min_seasonal_index) {
    Algorithms::HoltWintersForecasting::Api.instance.min_seasonal_index(
      Algorithms::HoltWintersForecasting::ICMP_FLOOD
    )
  }
  let(:legal_page) { 1 }
  let(:legal_page_size) { 1 }
  let(:illegal_names) {
    [nil, 1, '']
  }
  let(:illegal_ip_addresses) {
    [nil, '1', '1.3.4', -1]
  }
  let(:illegal_ids) {
    [nil, '1', '1.3.4', -1]
  }
  let(:illegal_friendly_resource_hashes) {
    [nil, {}, '1', 2, []]
  }
  let(:illegal_pages) {
    [nil, '1', 0, -1]
  }
  let(:illegal_page_sizes) {
    [nil, '1', 0, -1]
  }
  let(:illegal_cyber_reports) {
    [nil, 1, '2']
  }
  let(:illegal_friendly_resources) {
    [nil, '1', 2, {}]
  }

  it 'Throws an error when creating a new friendly resource with an illegal name.' do
    illegal_names.each do |name|
      expect {
        archive_api.new_friendly_resource(name, legal_ip_address)
      }.to raise_error(StandardError, /must be an instance of #{String.name}/)
    end
  end

  it 'Throws an error when creating a new friendly resource with an illegal ip address.' do
    illegal_ip_addresses.each do |address|
      expect {
        archive_api.new_friendly_resource(legal_name, address)
      }.to raise_error(StandardError, /#{address} does not match expected format/)
    end
  end

  it 'Creates a new friendly resource object.' do
    expect(
      archive_api.new_friendly_resource(legal_name, legal_ip_address).class
    ).to eql(FriendlyResource)
  end

  it 'Throws an error when persisting an illegal friendly resource.' do
    illegal_friendly_resources.each do |f|
      expect {
        archive_api.persist_friendly_resource(f)
      }.to raise_error(StandardError, /must be an instance of #{FriendlyResource.name}/)
    end
  end

  it 'Persists a friendly resource object.' do
    expect {
      archive_api.persist_friendly_resource(friendly_resource)
    }.to_not raise_error
  end

  it 'Throws an error when retrieving a persisted friendly resource by an illegal ip address.' do
    illegal_ip_addresses.each do |address|
      expect {
        archive_api.friendly_resource_by_ip(address)
      }.to raise_error(StandardError, /#{address} does not match expected format/)
    end
  end

  it 'Retrieves a persisted friendly resource by an ip address.' do
    archive_api.persist_friendly_resource(friendly_resource)
    expect(
      archive_api.friendly_resource_by_ip(friendly_resource.ip_address).inspect
    ).to eql(friendly_resource.inspect)
  end

  it 'Throws an error when retrieving a persisted friendly resource by an illegal id.' do
    illegal_ids.each do |id|
      expect {
        archive_api.friendly_resource_by_id(id)
      }.to raise_error(
        StandardError,
        /(#{id} must be an instance of #{Integer.name}|#{id} must be a non-negative #{Integer.name})/
      )
    end
  end

  it 'Retrieves a persisted friendly resource by an id.' do
    archive_api.persist_friendly_resource(friendly_resource)
    id = archive_api.friendly_resource_by_ip(friendly_resource.ip_address).id
    expect(
      archive_api.friendly_resource_by_id(id).inspect
    ).to eql(friendly_resource.inspect)
  end

  it 'Throws an error when creating a new friendly resource object from an illegal hash.' do
    illegal_friendly_resource_hashes.each do |h|
      expect {
        archive_api.new_friendly_resource_from_hash(h)
      }.to raise_error(
        StandardError,
        /(must be an instance of #{Hash.name}|must be an instance of #{String.name})/
      )
    end
  end

  it 'Creates a new friendly resource object from a hash.' do
    expect(
      archive_api.new_friendly_resource_from_hash(friendly_resource_hash).class
    ).to eql(FriendlyResource)
  end

  it 'Throws an error when paginating over the persisted friendly resources with an illegal page.' do
    illegal_pages.each do |page|
      expect {
        archive_api.friendly_resources(page, legal_page_size)
      }.to raise_error(
        StandardError,
        /(must be an instance of #{Integer.name}|must be an instance of #{Integer.name} greater than 0)/
      )
    end
  end

  it 'Throws an error when paginating over the persisted friendly resources with an illegal page size.' do
    illegal_page_sizes.each do |size|
      expect {
        archive_api.friendly_resources(legal_page, size)
      }.to raise_error(
        StandardError,
        /(must be an instance of #{Integer.name}|must be an instance of #{Integer.name} greater than 0)/
      )
    end
  end

  it 'Paginates over the persisted friendly resources.' do
    friendly_resources_data = [
      { 'name' => legal_name, 'ip_address' => legal_ip_address },
      { 'name' => 'Demo_2', 'ip_address' => '79.181.31.5' },
      { 'name' => 'Demo_3', 'ip_address' => '79.181.31.6' },
      { 'name' => 'Demo_4', 'ip_address' => '79.181.31.7' }
    ]
    friendly_resources_data.each do |f|
      archive_api.persist_friendly_resource(
        archive_api.new_friendly_resource_from_hash(f)
      )
    end
    expect(
      archive_api.friendly_resources(legal_page, legal_page_size).size
    ).to eql(legal_page)
    expect(
      archive_api.friendly_resources(1, 4).size
    ).to eql(4)
    expect(
      archive_api.friendly_resources(2, 2).size
    ).to eql(2)
    expect(
      archive_api.friendly_resources(2, 3).size
    ).to eql(1)
    expect(
      archive_api.friendly_resources(3, 3).size
    ).to eql(0)
  end

  it 'Returns the amount of the persisted friendly resources.' do
    friendly_resources_data = [
      { 'name' => legal_name, 'ip_address' => legal_ip_address },
      { 'name' => 'Demo_2', 'ip_address' => '79.181.31.5' },
      { 'name' => 'Demo_3', 'ip_address' => '79.181.31.6' },
      { 'name' => 'Demo_4', 'ip_address' => '79.181.31.7' }
    ]
    count = 0
    expect(archive_api.friendly_resources_count).to eql(count)
    friendly_resources_data.each do |f|
      count += 1
      archive_api.persist_friendly_resource(
        archive_api.new_friendly_resource_from_hash(f)
      )
      expect(archive_api.friendly_resources_count).to eql(count)
    end
  end

  it 'Throws an error when a persisted friendly resource is retrieved by an illegal cyber report.' do
    illegal_cyber_reports.each do |report|
      expect {
        archive_api.friendly_resource_by_cyber_report(report)
      }.to raise_error(StandardError, /#{report} must be an instance of #{CyberReport.name}/)
    end
  end

  it 'Retrieves a persisted friendly resource by a cyber report.' do
    archive_api.persist_friendly_resource(friendly_resource)
    cyber_report = archive_api.new_cyber_report_object_for_friendly_resource(
      friendly_resource.ip_address,
      Departments::Shared::AnalysisType::ICMP_DOS_CYBER_REPORT,
      'seasonal_index' => icmp_dos_cyber_report_min_seasonal_index
    )
    archive_api.persist_cyber_report(cyber_report)
    expect(
      archive_api.friendly_resource_by_cyber_report(cyber_report).inspect
    ).to eql(friendly_resource.inspect)
  end
end
