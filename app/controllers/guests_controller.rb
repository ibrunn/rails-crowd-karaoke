class GuestsController < ApplicationController
  skip_before_action :authenticate_user!, only: :new
  before_action :set_session, only: [:new, :create]
  before_action :verify_session_joinable, only: [:new, :create]

  # GET /sessions/:uuid/guests/new
  # This is where QR code scanning leads guests
  def new
    @guest = @session.guests.build
  end

  # POST /sessions/:uuid/guests
  # Creates guest record and sets session cookie
  def create
    @guest = @session.guests.build(guest_params)

    if @guest.save
      # THIS IS THE KEY STEP: Set the guest_id in browser session
      session[:guest_id] = @guest.id

      # Broadcast new guest to host's big screen
      broadcast_guest_joined

      # Redirect to appropriate stage based on current session stage
      redirect_to green_room_guest_path
    else
      # Re-render form with validation errors
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_session
    @session = GameSession.find_by!(uuid: params[:uuid])
  end

  def verify_session_joinable
    # Only allow joining during welcome (0) or green room (1) stages
    unless [0, 1].include?(@session.current_stage)
      redirect_to root_path, alert: "This session is not currently accepting new guests."
      return false
    end

    # Check if session has reached guest limit
    if @session.guests.count >= 20 # Max guests
      redirect_to root_path, alert: "This session is full."
      return false
    end

    true
  end

  def guest_params
    params.require(:guest).permit(:nickname)
  end

  def broadcast_guest_joined
    # Update guest count and list on host's big screen
    Turbo::StreamsChannel.broadcast_update_to(
      "game_session_#{@session.uuid}_host",
      target: "guest-list",
      partial: "game_sessions/guest_list",
      locals: { session: @session }
    )

    # Update guest count display
    Turbo::StreamsChannel.broadcast_update_to(
      "game_session_#{@session.uuid}_host",
      target: "guest-count",
      partial: "game_sessions/guest_count",
      locals: { session: @session }
    )

    # If this moves session from empty to having guests, enable start button
    if @session.guests.count == 1 && @session.current_stage == 0
      Turbo::StreamsChannel.broadcast_update_to(
        "game_session_#{@session.uuid}_host",
        target: "start-button",
        partial: "game_sessions/start_button",
        locals: { session: @session, can_start: true }
      )
    end
  end

  def guest_destination_path
    # Route guest to current stage of the session
    # Solves the Race Condition Problem
    case @session.current_stage
    when 0, 1
      green_room_guest_path(@session.uuid)
    when 2
      genre_start_path(@session.uuid)
    when 3
      new_genre_votes_path(@session.uuid) # Will show genre voting
    when 3.5
      genre_result_guest_path(@session.uuid)
    when 4
      song_start_path(@session.uuid)
    when 5
      new_song_votes_path(@session.uuid) # Will show song voting
    when 5.5
      song_result_guest_path(@session.uuid)
    when 6
      sing_start_session_path(@session.uuid)
    when 7
      sing_start_path(@session.uuid) # Will show karaoke
    when 8
      sing_end_path(@session.uuid)
    else
      green_room_guest_path(@session.uuid)
    end
  end
end
