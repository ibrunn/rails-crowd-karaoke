require "rqrcode"
class GameSessionsController < ApplicationController
  before_action :authenticate_user!, except: [:green_room, :genre_start, :genre_result,
                                              :song_start, :song_result, :sing_start, :sing_end]
  before_action :set_session, only: [:show, :green_room, :genre_start, :genre_result,
                                     :song_start, :song_result, :sing_start, :sing_end]
  before_action :verify_host_or_guest, only: [:show, :green_room, :genre_start, :genre_result,
                                              :song_start, :song_result, :sing_start, :sing_end]

  def create
    @session = GameSession.create(current_stage: 0, user: current_user)
    # redirects to ../views/game_sessions/show.html.erb which is the green_room_host
    redirect_to green_room_host_path(@session.uuid)
  end

  def show
    # heroku url - to be changed when in production
    public_url = "https://crowd-karaoke-8f21f5696c65.herokuapp.com"
    # utilizing rqrcode gem to generate QR code with session url
    @qrcode = RQRCode::QRCode.new("#{public_url}/sessions/#{@session.uuid}/guests/new", color: :white)
  end

  def green_room
  end

  def genre_start
  end

  def genre_votes
  end

  def genre_result
  end

  def song_start
  end

  def song_votes
  end

  def song_result
  end

  def sing_start
  end

  def sing_end
  end


  # STAGE PROGRESSION - Core Stage Management Methods
  #
  # start_game method:
  # - Validate current stage is 1
  # - Call advance_to_stage(2)
  # - Broadcast stage change via Turbo Streams
  def start_game
    unless @session.current_stage == 1
      redirect_to root_path(@session.uuid), alert: "Game not ready to start"
      return
    end
    advance_to_stage(2)
  end

# advance_to_stage method:
# - Update current_stage and stage_started_at
# - Store stage-specific data in stage_data JSON
# - Broadcast updates to all connected users
# - Handle redirects/renders appropriately
def advance_to_stage(stage)
  # Update current_stage and stage_started_at
  stage_data = @session.stage_data || {}

  # Store any stage-specific data in stage_data JSON
  case stage
  when 2
    stage_data = {"previous_stage": 1, "transition_type": "auto", "host_initiated": true}
  when 3
    stage_data = {"previous_stage": 2, "transition_type": "auto", "host_initiated": false}
  when 3.5
    stage_data = {"previous_stage": 3, "transition_type": "auto", "host_initiated": false}
  when 4
    stage_data = {"previous_stage": 3.5, "transition_type": "auto", "host_initiated": false}
  when 5
    stage_data = {"previous_stage": 4, "transition_type": "auto", "host_initiated": false}
  when 5.5
    stage_data = {"previous_stage": 5, "transition_type": "auto", "host_initiated": false}
  when 6
    stage_data = {"previous_stage": 5.5, "transition_type": "manual", "host_initiated": true}
  when 7
    stage_data = {"previous_stage": 6, "transition_type": "manual", "host_initiated": true}
  when 8
    stage_data = {"previous_stage": 7, "transition_type": "manual", "host_initiated": true}
  end

  # Update the session with new stage, timestamp and data
  @session.update(
    current_stage: stage,
    stage_started_at: Time.current,
    stage_data: stage_data
  )

  # Broadcast stage change to all connected users
  Turbo::StreamsChannel.broadcast_update_to(
    "game_session_#{@session.uuid}_host",
    target: "game-stage-host",
    html: "Stage: #{stage}"
  )

  # Broadcast to guests as well
  Turbo::StreamsChannel.broadcast_update_to(
    "game_session_#{@session.uuid}_guests",
    target: "game-stage-guest",
    html: "Stage: #{stage}"
  )

  # Handle redirects/renders appropriately based on stage
  destination = case stage
  when 2 then genre_start_path(@session.uuid)
  when 3 then new_genre_votes_path(@session.uuid)
  when 3.5 then genre_result_guest_path(@session.uuid)
  when 4 then song_start_path(@session.uuid)
  when 5 then new_song_votes_path(@session.uuid)
  when 5.5 then song_result_guest_path(@session.uuid)
  when 6 then sing_start_path(@session.uuid)
  when 8 then sing_end_path(@session.uuid)
  else
    root_path
  end

  # Respond appropriately - either redirect or render JSON
  respond_to do |format|
    format.html { redirect_to destination }
    format.json { render json: { next_stage: stage, redirect_to: destination } }
  end

  return @session
end


  private


  def set_session
    @session = GameSession.find_by!(uuid: params[:uuid])
  end

end
