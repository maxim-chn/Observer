# frozen_string_literal: true

require 'rails_helper'
RSpec.describe 'ArchiveApi', type: :feature do
  context 'A number of persisted cyber reports' do
    before(:all) do
      friendly_resource = Departments::Archive::Api.instance.new_friendly_resource(
        'demo_1',
        IPAddr.new('79.181.31.10').to_i
      )
      friendly_resource.save
      friendly_resource_ip = friendly_resource.ip_address.to_i
      (0..5).each do |n|
        next_cyber_report = Departments::Archive::Api.instance.new_cyber_report_object_for_friendly_resource(
          friendly_resource_ip,
          Departments::Shared::AnalysisType::ICMP_DOS_CYBER_REPORT,
          seasonal_index: n
        )
        next_cyber_report.save
      end
    end
    subject(:archive_api) { Departments::Archive::Api.instance }
    let(:ip) { archive_api.all_friendly_resources(1, 1).first.ip_address.to_i }
    let(:cyber_report_type) { Departments::Shared::AnalysisType::ICMP_DOS_CYBER_REPORT }
    it 'Retrieves pages of CyberReports' do
      expect(archive_api.cyber_reports_by_friendly_resource_ip_and_type(
        ip,
        cyber_report_type,
        1,
        5
      ).size).to eql(5)
      expect(archive_api.cyber_reports_by_friendly_resource_ip_and_type(
        ip,
        cyber_report_type,
        2,
        2
      ).size).to eql(2)
      expect(archive_api.cyber_reports_by_friendly_resource_ip_and_type(
        ip,
        cyber_report_type,
        3,
        6
      ).size).to eql(0)
    end
    let(:cyber_report) {
      archive_api.cyber_reports_by_friendly_resource_ip_and_type(
        ip,
        cyber_report_type,
        1,
        1
      ).first
    }
    it 'Retrieves a CyberReport by id and type' do
      expect(archive_api.cyber_report_by_id_and_type(cyber_report.id, cyber_report_type)).to eql(cyber_report)
    end
    it 'Retrieves a CyberReport by FriendlyResource id, type and seasonal_index' do
      expect(archive_api.cyber_report_by_friendly_resource_ip_and_type_and_custom_attr(
               ip,
               cyber_report_type,
               seasonal_index: 2
             )).to be_an_instance_of(Dos::IcmpFloodReport)
    end
  end
end
