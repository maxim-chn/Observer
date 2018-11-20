require 'test_helper'

class Demo::FriendlyResourcesControllerTest < ActionDispatch::IntegrationTest
  test "demo_friendly_resources fetch" do
    get demo_friendly_resources_url
    assert_select "h1.title-page", "This is FriendlyResources main page"
  end

  test "new_demo_friendly_resource fetch" do
    get new_demo_friendly_resource_url
    assert_select "h1.title-page", "A form for FriendlyResource signup"
  end

  test "demo_friendly_resource fetch" do
    get demo_friendly_resource_path("none")
    assert_select "h1.title-page", "This is main page for FriendlyResource None"
  end

  test "edit_demo_friendly_resource" do
    get edit_demo_friendly_resource_path("none")
    assert_select "h1.title-page", "A form for FriendlyResource None edit"
  end
end # Demo::FriendlyResourcesControllerTest
