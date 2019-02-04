require 'rails_helper'
RSpec.describe 'FriendlyResource', type: :model do
  it 'Is retrievable from db' do
    FactoryGirl.create(:friendly_resource)
    archive_api = Departments::Archive::Api.instance
    friendly_resource = archive_api.friendly_resource_by_id(1)
    expect(friendly_resource).to be_instance_of(FriendlyResource)
  end
end
