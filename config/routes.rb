Rails.application.routes.draw do
  devise_for :users

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Stage 0 - Host Welcome Page
  root to: "pages#welcome"
  # Stage 0 - Host Create Session
  post "/sessions", to: "game_sessions#create"
  # Stage 1 - Host Green Room
  get  "/sessions/:uuid", to: "game_sessions#show", as: :session_by_uuid
  # Stage 1 - Guest Green Room / Join Game Session
  get "/sessions/:uuid/guests/new", to: "guests#new"
  post "/sessions/:uuid/guests", to: "guests#create"
  get "/sessions/:uuid/green_room", to: "game_sessions#green_room"
  # Stage 2 - Host+Guest Genre Intro
  get "/sessions/:uuid/genre_start", to: "game_sessions#genre_start"
  # Stage 3 - Guest Genre Voting
  get "/sessions/:uuid/genre_votes/new", to: "genre_votes#new"
  post "/sessions/:uuid/genre_votes", to: "genre_votes#create"
  # Stage 3.5 - Guest Genre Result
  get "/sessions/:uuid/genre_result", to: "game_sessions#genre_result"
  # Stage 4 - Host+Guest Song Intro
  get "/sessions/:uuid/song_start", to: "game_sessions#song_start"
  # Stage 5 - Guest Song Voting
  get "/sessions/:uuid/song_votes/new", to: "song_votes#new"
  post "/sessions/:uuid/song_votes", to: "song_votes#create"
  # Stage 5.5 - Guest Song Result
  get "/sessions/:uuid/song_result", to: "game_sessions#song_result"
  # Stage 6 - Host+Guest Sing Intro
  get "/sessions/:uuid/sing_start", to: "game_sessions#sing_start"
  # Stage 8 - Host+Guest Sing Outro
  get "/sessions/:uuid/sing_end", to: "game_sessions#sing_end"

end
