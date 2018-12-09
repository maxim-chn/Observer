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
    @friendlyResource  = FriendlyResource.find(friendlyResourceId)
    # render demo/friendly_resources/show.html.erb
  end

  def edit
    friendlyResourceId = params[:id]
    @friendlyResource = FriendlyResource.find(friendlyResourceId)
    # render demo/friendly_resources/edit.html.erb
  end

  def start_monitoring
    friendlyResourceId  = params[:friendly_resource_id]
    thinkTankDepartment = Departments::ThinkTank::ThinkTankApi.instance()
    thinkTankDepartment.monitorDos(friendlyResourceId)
    render plain: "REQUEST TO START ADDED TO QUEUE"
  end

  def stop_monitoring
    friendlyResourceId  = params[:friendly_resource_id]
    thinkTankDepartment = Departments::ThinkTank::ThinkTankApi.instance()
    thinkTankDepartment.stopMonitoring(friendlyResourceId)
    render plain: "REQUEST TO STOP ADDED TO QUEUE"
  end

end # Demo::FriendlyResourcesController
