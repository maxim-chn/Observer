module Demo::FriendlyResourcesHelper
  def getFriendlyResourceName(friendlyResource)
    name = "None"
    name = friendlyResource.name() unless friendlyResource.nil?
    return name
  end
end # Demo::FriendlyResourcesHelper
