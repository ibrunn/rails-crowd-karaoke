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

end
