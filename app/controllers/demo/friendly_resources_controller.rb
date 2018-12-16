class Demo::FriendlyResourcesController < ApplicationController
  
  def index
    page               = params[:page] ? params[:page] : 1
    pageSize           = params[:page_size] ? params[:page_size] : 10
    archiveApi         = Departments::Demo::Archive::ArchiveApi.instance()
    @friendlyResources = archiveApi.getAllFriendlyResources(page, pageSize)
    # render demo/friendly_resources/index.html.erb
  end

  def new
    # render demo/friendly_resources/new.html.erb
  end

  def show
    friendlyResourceId = params[:id]
    archiveApi         = Departments::Demo::Archive::ArchiveApi.instance()
    @friendlyResource = archiveApi.getFriendlyResourceById(friendlyResourceId)
    # render demo/friendly_resources/show.html.erb
  end

  def edit
    friendlyResourceId = params[:id]
    archiveApi         = Departments::Demo::Archive::ArchiveApi.instance()
    @friendlyResource = archiveApi.getFriendlyResourceById(friendlyResourceId)
    # render demo/friendly_resources/edit.html.erb
  end

  def start_monitoring
    friendlyResourceId  = params[:friendly_resource_id]
    thinkTankDepartment = Departments::Demo::ThinkTank::ThinkTankApi.instance()
    thinkTankDepartment.startMonitoring(friendlyResourceId)
    render plain: "REQUEST TO START ADDED TO QUEUE"
  end

  def stop_monitoring
    friendlyResourceId  = params[:friendly_resource_id]
    thinkTankDepartment = Departments::Demo::ThinkTank::ThinkTankApi.instance()
    thinkTankDepartment.stopMonitoring(friendlyResourceId)
    render plain: "REQUEST TO STOP ADDED TO QUEUE"
  end

end # Demo::FriendlyResourcesController
