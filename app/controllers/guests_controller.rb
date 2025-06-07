class GuestsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:new, :create]
  before_action :set_session, only: [:new, :create]
  before_action :verify_session_joinable, only: [:new, :create]

  # get "/sessions/:uuid/guests/new", to: "guests#new", as: :new_guest
  # This is where QR code scanning leads guests
  def new
    @guest = @session.guests.build
  end

  # post "/sessions/:uuid/guests", to: "guests#create", as: :create_guest
  # Creates guest record and sets session cookie
  def create
    @guest = @session.guests.build(guest_params)

    if @guest.save
      # THIS IS THE KEY STEP: Set the guest_id in browser session
      session[:guest_id] = @guest.id

      # Broadcast new guest to host's big screen
      broadcast_guest_joined

      # Route guest to current stage of the session
      # Solves the Race Condition Problem
      redirect_to guest_destination_path

    else
      # Re-render form with validation errors
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_session
    @session = GameSession.find_by!(uuid: params[:uuid])
  end

  def guest_params
    params.require(:guest).permit(:nickname)
  end

  def verify_session_joinable
    # Only allow joining during welcome (0) or green room (1) stages
    unless [0.0, 1.0].include?(@session.current_stage)
      # backlog: redirect to not_joinable.html.erb with proper user feedback
      redirect_to root_path, alert: "This session is not currently accepting new guests."
      return false
    end

    # Check if session has reached guest limit
    if @session.guests.count >= 25 # Max guests
      # backlog: redirect to not_joinable.html.erb with proper user feedback
      redirect_to root_path, alert: "This session is full."
      return false
    end

    return true
  end

  def broadcast_guest_joined
    # Update guest count and list on host's big screen
    Turbo::StreamsChannel.broadcast_update_to(
      "game_session_#{@session.uuid}_host",
      target: "guest-list-host",
      partial: "game_sessions/guest_list",
      locals: { session: @session }
    )

    # Update guest count display on host's big screen
    Turbo::StreamsChannel.broadcast_update_to(
      "game_session_#{@session.uuid}_host",
      target: "guest-count-host",
      partial: "game_sessions/guest_count",
      locals: { session: @session }
    )

    # If session moves from empty to having guests, enable start button on host's big screen
    if @session.guests.count >= 1 && [0.0, 1.0].include?(@session.current_stage)
      Turbo::StreamsChannel.broadcast_update_to(
        "game_session_#{@session.uuid}_host",
        target: "start-button-host",
        partial: "game_sessions/start_button",
        locals: { session: @session, can_start: true }
      )
    end

    # Update guest count and list on guest's mobile devices
    Turbo::StreamsChannel.broadcast_update_to(
      "game_session_#{@session.uuid}_guest",
      target: "guest-list",
      partial: "game_sessions/guest_list",
      locals: { session: @session }
    )

    # Update guest count display on guest's mobile devices
    Turbo::StreamsChannel.broadcast_update_to(
      "game_session_#{@session.uuid}_guest",
      target: "guest-count",
      partial: "game_sessions/guest_count",
      locals: { session: @session }
    )

  end

  def guest_destination_path
    # Route guest to current stage of the session
    # Solves the Race Condition Problem
    case @session.current_stage
      when 0.0, 1.0 then green_room_guest_path(@session.uuid)
      when 2.0 then genre_start_path(@session.uuid)
      when 3.0 then new_genre_votes_path(@session.uuid) # Will show genre voting
      when 3.5 then genre_result_guest_path(@session.uuid)
      when 4.0 then song_start_path(@session.uuid)
      when 5.0 then new_song_votes_path(@session.uuid) # Will show song voting
      when 5.5 then song_result_guest_path(@session.uuid)
      when 6.0 then sing_start_session_path(@session.uuid)
      when 7.0 then sing_start_path(@session.uuid) # Will show karaoke
      when 8.0 then sing_end_path(@session.uuid)
    else
      green_room_guest_path(@session.uuid)
    end
  end
end
