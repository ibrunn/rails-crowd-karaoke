class GuestsController < ApplicationController
  before_action :set_session, only: [:new, :create]
  before_action :verify_session_joinable, only: [:new, :create]

  # GET /sessions/:session_uuid/guests/new
  # This is where QR code scanning leads guests
  def new
    @guest = @session.guests.build
    @current_guest_count = @session.guests.count
  end

  # POST /sessions/:session_uuid/guests
  # Creates guest record and sets session cookie
  def create
    @guest = @session.guests.build(guest_params)

    if @guest.save
      # THIS IS THE KEY STEP: Set the guest_id in browser session
      session[:guest_id] = @guest.id

      # Broadcast new guest to host's big screen
      broadcast_guest_joined

      # Redirect to appropriate stage based on current session stage
      redirect_to guest_destination_path
    else
      # Re-render form with validation errors
      @session_name = @session.name || "Karaoke Session"
      @current_guest_count = @session.guests.count
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_session
    @session = Session.find_by!(uuid: params[:session_uuid])
  end

  def verify_session_joinable
    # Only allow joining during welcome (0) or green room (1) stages
    unless [0, 1].include?(@session.current_stage)
      redirect_to root_path, alert: "This session is not currently accepting new guests."
      return false
    end
  end
end
