# frozen_string_literal: true

require 'rails_helper'
RSpec.describe 'ArchiveApi', type: :feature do
  context 'A number of persisted friendly resources' do
    before(:all) do
      (1..5).each do |n|
        next_friendly_resource = Departments::Archive::Api.instance.new_friendly_resource(
          "demo_#{n}",
          IPAddr.new("79.181.31.#{n}").to_i
        )
        next_friendly_resource.save
      end
    end
    subject(:archive_api) { Departments::Archive::Api.instance }
    it 'Retrieves pages of friendly resources' do
      expect(archive_api.all_friendly_resources(1, 5).size).to eql(5)
      expect(archive_api.all_friendly_resources(2, 2).size).to eql(2)
    end
    let(:friendly_resource) { archive_api.all_friendly_resources(1, 1).first }
    it 'Retrieves friendly resource by id' do
      expect(archive_api.friendly_resource_by_id(friendly_resource.id)).to eql(friendly_resource)
    end
    it 'Retrieves friendly resource by ip' do
      expect(archive_api.friendly_resource_by_ip(friendly_resource.ip_address)).to eql(friendly_resource)
    end
    it 'Retrieves friendly resource by cyber report' do
      cyber_report = archive_api.new_cyber_report_object_for_friendly_resource(
        friendly_resource.ip_address,
        Departments::Shared::AnalysisType::ICMP_DOS_CYBER_REPORT,
        seasonal_index: 0
      )
      archive_api.persist_cyber_report(cyber_report)
      expect(archive_api.friendly_resource_by_cyber_report(cyber_report)).to eql(friendly_resource)
    end
  end
end
