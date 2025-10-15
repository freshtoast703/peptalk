Rails.application.routes.draw do
  # Mount Devise routes under /auth to avoid conflicting with the app's UsersController
  devise_for :users, path: "auth"

  resources :posts
  # Use Devise registrations for new/create (sign up). Keep other user admin actions.
  resources :users, except: [:new, :create]
  # Public share link route
  get "/s/:token", to: "share_links#show", as: :share_link
  # Admin routes to create and revoke share links
  resources :share_links, only: [ :create, :destroy ]
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
