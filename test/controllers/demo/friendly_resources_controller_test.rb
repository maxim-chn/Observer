require 'test_helper'

class Demo::FriendlyResourcesControllerTest < ActionDispatch::IntegrationTest
  # test "demo_friendly_resources fetch" do
  #   get demo_friendly_resources_url
  #   assert_select "h1.title-page", "This is FriendlyResources main page"
  # end

  # test "new_demo_friendly_resource fetch" do
  #   get new_demo_friendly_resource_url
  #   assert_select "h1.title-page", "A form for FriendlyResource signup"
  # end

  # test "demo_friendly_resource fetch" do
  #   friendlyResource = FriendlyResource.first()
  #   get demo_friendly_resource_path(friendlyResource)
  #   assert(
  #     css_select("h1.title-page").first().text().include?("This is main page for FriendlyResource"),
  #     "Unexpected title for demo_friendly_resource fetch"
  #   )
  # end

  # test "edit_demo_friendly_resource" do
  #   friendlyResource = FriendlyResource.first()
  #   get edit_demo_friendly_resource_path(friendlyResource)
  #   assert(
  #     css_select("h1.title-page").first().text().include?("A form for FriendlyResource"),
  #     "Unexpected title for edit_demo_friendly_resource fetch"
  #   )
  # end
end # Demo::FriendlyResourcesControllerTest
