Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  scope :demo, module: "demo", as: "demo" do
    get "welcome" => "welcome#index", as: "homepage"
    resources :friendly_resources, only: [:index, :show, :new, :edit] do
      resources :cyber_reports, only: [:index]
    end
    resources :cyber_reports, only: [:show]
  end
  root to: "demo/welcome#index" # root to: homepage_path
end # Rails.application.routes.draw
