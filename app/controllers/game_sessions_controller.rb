require "rqrcode"
class GameSessionsController < ApplicationController
  before_action :authenticate_user!, except: [:green_room, :genre_start, :genre_result,
                                              :song_start, :song_result, :sing_start, :sing_end, :singing,
                                              :start_game, :advance_to_stage, :advance_stage_handler]
  before_action :set_session, only: [:show, :green_room, :genre_start, :genre_result,
                                     :song_start, :song_result, :sing_start, :sing_end, :singing,
                                     :start_game, :advance_to_stage, :advance_stage_handler]
  before_action :verify_host_or_guest, only: [:show, :green_room, :genre_start, :genre_result,
                                              :song_start, :song_result, :sing_start, :sing_end, :singing,
                                              :start_game, :advance_to_stage, :advance_stage_handler]

  def create
    @session = GameSession.create(
      user: current_user,
      current_stage: 0.0,
      stage_started_at: Time.current
    )
    advance_to_stage(1.0)
  end

  def show
    public_url = "https://crowd-karaoke-8f21f5696c65.herokuapp.com"
    @qrcode = RQRCode::QRCode.new("#{public_url}/sessions/#{@session.uuid}/guests/new", color: :white)
  end

  def green_room
  end

  def genre_start
  end

  def genre_result
  end

  def song_start
  end

  def song_result
  end

  def sing_start
  end

  def singing
    # Stage 7 - actual singing/performance
  end

  def sing_end
  end

  def start_game
    unless @session.user == current_user
      redirect_to root_path, alert: "Only the host can start the game"
      return
    end

    unless @session.current_stage == 1.0
      redirect_to green_room_host_path(@session.uuid), alert: "Game not ready to start"
      return
    end

    advance_to_stage(2.0)
  end

  def advance_stage_handler
    stage = params[:stage].to_f
    advance_to_stage(stage)
  end

  def advance_to_stage(stage)
    normalized_stage = stage.to_f

    # Validation to prevent invalid stage transitions
    unless valid_stage_transition?(@session.current_stage, normalized_stage)
      redirect_to root_path, alert: "Invalid stage transition"
      return false
    end

    # Store stage-specific data in stage_data JSON
    stage_data = build_stage_data(@session.current_stage, normalized_stage)

    # Update the session
    @session.update(
      current_stage: normalized_stage,
      stage_started_at: Time.current,
      stage_data: stage_data
    )

    # Get centralized destinations for both host and guest
    host_destination = get_stage_destination(normalized_stage, :host, @session)
    guest_destination = get_stage_destination(normalized_stage, :guest, @session)

    # Broadcast to hosts
    Turbo::StreamsChannel.broadcast_update_to(
      "game_session_#{@session.uuid}_host",
      action: "append",
      target: "head",  # <head> element always exists
      html: %(<script>
        setTimeout(function() {
          window.location.href = "#{host_destination}";
        }, 100);
      </script>)
    )

    # Broadcast to guests
    Turbo::StreamsChannel.broadcast_update_to(
      "game_session_#{@session.uuid}_guest",
      action: "append",
      target: "head",  # <head> element always exists
      html: %(<script>
        setTimeout(function() {
          window.location.href = "#{guest_destination}";
        }, 100);
      </script>)
    )

    # Determine destination for current user
    is_host = @session.user == current_user
    destination = is_host ? host_destination : guest_destination

    respond_to do |format|
      format.html { redirect_to destination }
      format.json { render json: { next_stage: normalized_stage, redirect_to: destination } }
    end

    return @session
  end

  private

  def set_session
    @session = GameSession.find_by!(uuid: params[:uuid])
  end

  def build_stage_data(previous_stage, new_stage)
    {
      previous_stage: previous_stage,
      transition_type: determine_transition_type(new_stage),
      host_initiated: host_initiated_transition?(new_stage),
      transitioned_at: Time.current
    }
  end

  def determine_transition_type(stage)
    auto_stages = [3.0, 3.5, 4.0, 5.0, 5.5, 8.0]
    auto_stages.include?(stage) ? "auto" : "manual"
  end

  def host_initiated_transition?(stage)
    host_stages = [1.0, 2.0, 7.0]
    host_stages.include?(stage)
  end

  # Stage Transition Validation
  def valid_stage_transition?(current_stage, new_stage)
    current = current_stage.to_f
    new = new_stage.to_f

    valid_transitions = {
      0.0 => [1.0],   # Welcome → Green room
      1.0 => [2.0],   # Green room → Genre start
      2.0 => [3.0],   # Genre start → Genre voting
      3.0 => [3.5],   # Genre voting → Genre result
      3.5 => [4.0],   # Genre result → Song start
      4.0 => [5.0],   # Song start → Song voting
      5.0 => [5.5],   # Song voting → Song result
      5.5 => [6.0],   # Song result → Sing start
      6.0 => [7.0],   # Sing start → Singing
      7.0 => [8.0],   # Singing → Sing end
      8.0 => [1.0]    # Sing end → back to Green room
    }

    valid_transitions[current]&.include?(new)
  end
end
