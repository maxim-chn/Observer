class Demo::FriendlyResourcesController < ApplicationController
  def index
    @friendlyResources = FriendlyResource.all()
    # render demo/friendly_resources/index.html.erb
  end

  def new
    # render demo/friendly_resources/new.html.erb
  end

  def show
    friendlyResourceId = params[:id]
    @friendlyResource = FriendlyResource.find(friendlyResourceId)
    # render demo/friendly_resources/show.html.erb
  end

  def edit
    friendlyResourceId = params[:id]
    @friendlyResource = FriendlyResource.find(friendlyResourceId)
    # render demo/friendly_resources/edit.html.erb
  end
end # Demo::FriendlyResourcesController
