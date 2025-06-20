Rails.application.routes.draw do
  devise_for :users

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # S T A G E S
  post "/sessions/:uuid/start_game", to: "game_sessions#start_game", as: :start_game
  get "/sessions/:uuid/advance_stage/:stage", to: "game_sessions#advance_stage_handler", as: :advance_stage

  # S T A R T
  # Stage 0 - Host Welcome Page
  root to: "pages#welcome"
  # Stage 0 - Host Create Session
  post "/sessions", to: "game_sessions#create", as: :create_session

  # J O I N I N G
  # Stage 1 - Host Green Room
  get  "/sessions/:uuid", to: "game_sessions#show", as: :green_room_host
  # Stage 1 - Guest Green Room / Join Game Session
  get "/sessions/:uuid/guests/new", to: "guests#new", as: :new_guest
  post "/sessions/:uuid/guests", to: "guests#create", as: :create_guest
  get "/sessions/:uuid/green_room", to: "game_sessions#green_room", as: :green_room_guest

  # G E N R E
  # Stage 2 - Host+Guest Genre Intro
  get "/sessions/:uuid/genre_start", to: "game_sessions#genre_start", as: :genre_start
  # Stage 3 - Guest Genre Voting
  get "/sessions/:uuid/genre_votes/new", to: "genre_votes#new", as: :new_genre_votes
  post "/sessions/:uuid/genre_votes", to: "genre_votes#create", as: :game_session_genre_votes
  get "/sessions/:uuid/genre_votes/:id", to: "genre_votes#show", as: :genre_vote
  get "/sessions/:uuid/genre_stats", to: "game_sessions#genre_stats", as: :genre_stats
  # Stage 3.5 - Guest Genre Result
  get "/sessions/:uuid/genre_result", to: "game_sessions#genre_result", as: :genre_result

  # S O N G
  # Stage 4 - Host+Guest Song Intro
  get "/sessions/:uuid/song_start", to: "game_sessions#song_start", as: :song_start
  # Stage 5 - Guest Song Voting
  get "/sessions/:uuid/song_votes/new", to: "song_votes#new", as: :new_song_votes
  post "/sessions/:uuid/song_votes", to: "song_votes#create", as: :create_song_votes
  get "/sessions/:uuid/song_stats", to: "game_sessions#song_stats", as: :song_stats
  # Stage 55 - Guest Song Result
  get "/sessions/:uuid/song_result", to: "game_sessions#song_result", as: :song_result

  # S I N G I N G
  # Stage 6 - Host+Guest Sing Intro
  get "/sessions/:uuid/sing_start", to: "game_sessions#sing_start", as: :sing_start
  # Stage 8 - Host+Guest Sing Outro
  get "/sessions/:uuid/sing_end", to: "game_sessions#sing_end", as: :sing_end

end
