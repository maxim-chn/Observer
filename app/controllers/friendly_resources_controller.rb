# frozen_string_literal: true

##
# Action View Controller for FriendlyResource.
# [consumes] Departments::Archive::Api.
#            Departments::ThinkTank::Api.
class FriendlyResourcesController < ApplicationController
  def index
    page = params[:page] || 1
    page_size = params[:page_size] || 10
    archive_api = Departments::Archive::Api.instance
    @friendly_resources = archive_api.all_friendly_resources(page, page_size)
  end

  def new
    archive_api = Departments::Archive::Api.instance
    @friendly_resource = archive_api.new_empty_friendly_resource
    # will render new.html.erb
  end

  def show
    friendly_resource_id = params[:id]
    archive_api = Departments::Archive::Api.instance
    @friendly_resource = archive_api.friendly_resource_by_id(friendly_resource_id)
  end

  def edit
    friendly_resource_id = params[:id]
    archive_api = Departments::Archive::Api.instance
    @friendly_resource = archive_api.friendly_resource_by_id(friendly_resource_id)
  end

  def create
    archive_api = Departments::Archive::Api.instance
    begin
      @friendly_resource = archive_api.new_friendly_resource_from_hash(params['friendly_resource'])
      if archive_api.persist_friendly_resource(@friendly_resource)
        redirect_to(@friendly_resource, notice: 'Friendly resource has been created successfully.')
      else
        render action: "new", notice: 'Something went wrong with persisting new Friendly Resource'
      end
    rescue StandardError => e
      Rails.logger.error(e.message)
      render action: "new", notice: 'Something went wrong with creating new Friendly Resource'
    end
  end

  def start_monitoring
    friendly_resource_id = params[:friendly_resource_id]
    @friendly_resource = Departments::Archive::Api.instance.friendly_resource_by_id(friendly_resource_id)
    think_tank_api = Departments::ThinkTank::Api.instance
    begin
      think_tank_api.start_monitoring(friendly_resource_id)
      redirect_to(@friendly_resource, notice: 'Succeeded to start monitoring.')
    rescue StandardError => e
      Rails.logger.error(e.message)
      redirect_to(@friendly_resource, notice: 'Failed to start monitoring.')
    end
  end

  def stop_monitoring
    friendly_resource_id = params[:friendly_resource_id]
    @friendly_resource = Departments::Archive::Api.instance.friendly_resource_by_id(friendly_resource_id)
    think_tank_api = Departments::ThinkTank::Api.instance
    begin
      think_tank_api.stop_monitoring(friendly_resource_id)
      redirect_to(@friendly_resource, notice: 'Succeeded to stop monitoring.')
    rescue StandardError => e
      Rails.logger.error(e.message)
      redirect_to(@friendly_resource, notice: 'Failed to stop monitoring.')
    end
  end
end
