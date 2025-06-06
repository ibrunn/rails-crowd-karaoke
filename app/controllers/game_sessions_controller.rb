require "rqrcode"
class GameSessionsController < ApplicationController
  before_action :authenticate_user!, except: [:show, :green_room, :genre_start, :genre_result,
                                              :song_start, :song_result, :sing_start, :sing_end]
  before_action :set_session, only: [:show, :green_room, :genre_start, :genre_result,
                                     :song_start, :song_result, :sing_start, :sing_end]
  before_action :verify_host_or_guest, only: [:show, :green_room, :genre_start, :genre_result,
                                              :song_start, :song_result, :sing_start, :sing_end]

  def create
    @session = GameSession.create(current_stage: 0, user: current_user)
    redirect_to green_room_host_path(@session.uuid)
  end

  def show
    public_url = "https://crowd-karaoke-8f21f5696c65.herokuapp.com"
    @qr = RQRCode::QRCode.new("#{public_url}/sessions/#{@session.uuid}/guests/new")
  end

  def green_room
  end

  def genre_start
  end

  def genre_votes
  end

  def genre_result
  end

  def song_votes
  end

  def song_start
  end

  def song_result
  end

  def sing_start
  end

  def sing_end
  end


  private

  def set_session
    @session = GameSession.find_by!(uuid: params[:uuid])
  end

  def verify_host_or_guest
    is_host = @session.user == current_user
    is_guest = current_guest_for_session
    redirect_to root_path unless is_host || is_guest
  end

  # This method identifies which guest record corresponds to the current
  # browser session accessing the karaoke session.
  def current_guest_for_session
    return nil unless session[:guest_id]
    # session[:guest_id] is stored in the browser's encrypted session cookie
    # This gets set when a guest joins via QR code and submits their nickname
    # If no guest_id exists, this person hasn't joined as a guest → return nil
    @session.guests.find_by(id: session[:guest_id])
    # Looks up the guest record within this specific karaoke session
    # The guest must belong to @session (not just any session)
    # Returns the Guest object if found, nil if not found
  end

end
