# frozen_string_literal: true

module Demo
  ##
  # This class consumes [ArchiveApi] and [ThinkTankApi].
  class FriendlyResourcesController < ApplicationController
    # Renders a view template with a set of [FriendlyResource].
    def index
      page = params[:page] || 1
      page_size = params[:page_size] || 10
      archive_api = Departments::Demo::Archive::Api.instance
      @friendly_resources = archive_api.getAllFriendlyResources(page, page_size)
    end

    # Renders a view template with a form for a new [FriendlyResource].
    # TODO: edit template to actually have form with input fields.
    def new
      # render demo/friendly_resources/new.html.erb.
    end

    # Renders a view template with particular [FriendlyResource].
    def show
      friendly_resource_id = params[:id]
      archive_api = Departments::Demo::Archive::Api.instance
      @friendly_resource = archive_api.getFriendlyResourceById(friendly_resource_id)
    end

    # Renders a view templste with a form for a existing [FriendlyResource].
    # The details of the form can be edited and submitted.
    def edit
      friendly_resource_id = params[:id]
      archive_api = Departments::Demo::Archive::Api.instance
      @friendly_resource = archive_api.getFriendlyResourceById(friendly_resource_id)
    end
  end
end
