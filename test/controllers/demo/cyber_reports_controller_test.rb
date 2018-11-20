require 'test_helper'

class Demo::CyberReportsControllerTest < ActionDispatch::IntegrationTest
  test "demo_friendly_resource_cyber_reports fetch" do
    get demo_friendly_resource_cyber_reports_url("None")
    assert_select "h1.title-page", "This is CyberReports main page for FriendlyResource None"
  end

  test "demo_cyber_report fetch" do
    get demo_cyber_report_url("None")
    assert css_select(".title-page").first().text().include?("This is a page for None CyberReport from")
  end
end # Demo::CyberReportsControllerTest
