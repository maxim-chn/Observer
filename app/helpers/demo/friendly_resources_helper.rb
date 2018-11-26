module Demo::FriendlyResourcesHelper
  require "ipaddr"
  def getFriendlyResourceName(friendlyResource)
    name = "None"
    name = friendlyResource.name() unless friendlyResource.nil?
    return name
  end
  def getFriendlyResourceIpAddress(friendlyResource)
    ipAddress = "None"
    ipAddress = IPAddr.new(friendlyResource.ip_address(), Socket::AF_INET)
    return ipAddress.to_s
  end
  def getpageTitleForFriendlyResource(pageDetails)
    return "FriendlyResources | #{pageDetails}"
  end
end # Demo::FriendlyResourcesHelper
