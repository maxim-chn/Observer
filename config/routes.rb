# frozen_string_literal: true

##
# This is where we connect our routes to relevant controllers.
# @see http://guides.rubyonrails.org/routing.html
Rails.application.routes.draw do
  get 'welcome' => 'welcome#index', as: 'homepage'
  resources :friendly_resources, only: %i[index show new edit create] do
    get 'start_monitoring' => 'friendly_resources#start_monitoring'
    get 'stop_monitoring'  => 'friendly_resources#stop_monitoring'
    resources :cyber_reports, only: [:index]
    get 'show_reports/:type' => 'cyber_reports#show_reports'
  end
  scope :backend_api, module: 'backend_api', as: 'backend_api' do
    resources :dos_icmp_intelligence, only: [:create] do
    end
  end
  root to: 'welcome#index' # root to: homepage_path
  # To access Sidekiq Dashboard
  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'
end
