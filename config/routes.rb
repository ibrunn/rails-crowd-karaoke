Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  # Host
  get "/sessions/:uuid/genre_start", to: "sessions#genre_start"
  get "/sessions/:uuid/genres_result", to: "sessions#genre_result"
  get "/sessions/:uuid/song_start", to: "sessions#song_start"
  get "/sessions/:uuid/song_result", to: "sessions#song_result"
  get "/sessions/:uuid/sing_start", to: "sessions#sing_start"
  get "/sessions/:uuid/sing_end", to: "sessions#sing_end"
  get "/sessions/:uuid/green_room", to: "sessions#green_room"

  post "/sessions/:uuid/genre_votes", to: "sessions#create"

  # Guests
end
