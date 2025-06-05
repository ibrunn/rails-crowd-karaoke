require "rqrcode"
class GameSessionsController < ApplicationController
  before_action :authenticate_user!, except: [:show, :green_room, :genre_start, :genre_result,
                                              :song_start, :song_result, :sing_start, :sing_end]
  before_action :set_session, only: [:show, :green_room, :genre_start, :genre_result,
                                     :song_start, :song_result, :sing_start, :sing_end]
  before_action :verify_host_or_guest, only: [:show, :green_room, :genre_start, :genre_result,
                                              :song_start, :song_result, :sing_start, :sing_end]

  def create
  @session = current_user.game_sessions.new(current_stage: 0)

  if @session.save
    redirect_to session_by_uuid_path(@session.uuid)
  else
    flash[:alert] = @session.errors.full_messages.to_sentence
    redirect_to root_path
  end
  end

  def show

      @session = GameSession.find_by!(uuid: params[:uuid])

          #   full_url = session_by_uuid_url(@session.uuid)
    #   @qr = RQRCode::QRCode.new(full_url)
    #
    # Here, we’ll encode only the raw UUID:

    @qr = RQRCode::QRCode.new("https://crowd-karaoke-8f21f5696c65.herokuapp.com/#{@session.uuid}/guests/new")
    # In your view, you can now safely do: <%= @session.uuid %>
  end

  def genre_start
  end

  def genre_result
  end

  def genre_votes
  end

  def song_start
  end

  def song_result
  end

  def sing_start
  end

  def sing_end
  end

  def green_room
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
