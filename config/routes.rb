# frozen_string_literal: true

##
# This is where we connect our routes to relevant controllers.
# @see http://guides.rubyonrails.org/routing.html
Rails.application.routes.draw do
  scope :demo, module: 'demo', as: 'demo' do
    get 'welcome' => 'welcome#index', as: 'homepage'
    resources :friendly_resources, only: %i[index show new edit] do
      get 'start_monitoring' => 'friendly_resources#startMonitoring'
      get 'stop_monitoring'  => 'friendly_resources#stopMonitoring'
      resources :cyber_reports, only: [:index]
    end
    scope :backend_api, module: 'backend_api', as: 'backendApi' do
      resources :dos_icmp_intelligence, only: [:create] do
      end
    end
    resources :cyber_reports, only: [:show]
  end
  root to: 'demo/welcome#index' # root to: homepage_path
  # To access Sidekiq Dashboard
  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'
end
