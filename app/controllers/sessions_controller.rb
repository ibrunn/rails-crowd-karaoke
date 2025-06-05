require "rqrcode"

class SessionsController < ApplicationController

  def index
  end

  def create
   @session = Session.create
   @session.user = current_user
    @session.save
   redirect_to session_by_uuid_path(@session.uuid)
  end
  
  def show
    @session = Session.find_by!(uuid: params[:uuid])
    # @session
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
end
