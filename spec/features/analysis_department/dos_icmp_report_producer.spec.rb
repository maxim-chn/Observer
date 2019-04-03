# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'DosIcmpReportProducerService', type: :feature do
  subject(:dos_icmp_report_producer) { Departments::Analysis::Services::DosIcmpCyberReport.instance }
  let(:illegal_ip_nil) { nil }
  let(:illegal_ip_string) { '12' }
  let(:illegal_data) { 3 }
  let(:legal_ip) { IPAddr.new('79.181.31.4').to_i }
  let(:legal_data) { { 'incoming_req_count' => 12 } }

  it 'Throws an error when illegal ip & legal data' do
    expect {
      dos_icmp_report_producer.queue_dos_icmp_report(illegal_ip_nil, legal_data)
    }.to raise_error(StandardError)
    expect {
      dos_icmp_report_producer.queue_dos_icmp_report(illegal_ip_string, legal_data)
    }.to raise_error(StandardError)
  end

  it 'Throws an error when legal ip & illegal data' do
    expect {
      dos_icmp_report_producer.queue_dos_icmp_report(legal_ip, legal_data)
    }.to raise_error(StandardError)
  end
end
