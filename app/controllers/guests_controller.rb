class GuestsController < ApplicationController
  include StageRouting

  skip_before_action :authenticate_user!, only: [:new, :create]
  before_action :set_session, only: [:new, :create]
  before_action :verify_session_joinable, only: [:new, :create]

  def new
    @guest = @session.guests.build
  end

  def create
    @guest = @session.guests.build(guest_params)

    if @guest.save
      session[:guest_id] = @guest.id
      broadcast_guest_joined

      # Use centralized routing with consistent float types
      destination = get_stage_destination(@session.current_stage, :guest, @session)
      redirect_to destination
    else
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
    # Only allow joining during welcome (0.0) or green room (1.0) stages
    current_stage = @session.current_stage.to_f
    unless [0.0, 1.0].include?(current_stage)
      redirect_to root_path, alert: "This session is not currently accepting new guests."
      return false
    end

    if @session.guests.count >= 25
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

    Turbo::StreamsChannel.broadcast_update_to(
      "game_session_#{@session.uuid}_host",
      target: "guest-count-host",
      partial: "game_sessions/guest_count",
      locals: { session: @session }
    )

    # Enable start button if conditions are met
    current_stage = @session.current_stage.to_f
    if @session.guests.count >= 1 && [0.0, 1.0].include?(current_stage)
      Turbo::StreamsChannel.broadcast_update_to(
        "game_session_#{@session.uuid}_host",
        target: "start-button-host",
        partial: "game_sessions/start_button",
        locals: { session: @session, can_start: true }
      )
    end

    # Update guest interfaces
    Turbo::StreamsChannel.broadcast_update_to(
      "game_session_#{@session.uuid}_guest",
      target: "guest-list",
      partial: "game_sessions/guest_list",
      locals: { session: @session }
    )

    Turbo::StreamsChannel.broadcast_update_to(
      "game_session_#{@session.uuid}_guest",
      target: "guest-count",
      partial: "game_sessions/guest_count",
      locals: { session: @session }
    )
  end
end
