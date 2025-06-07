class SongVotesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:new, :create]
  before_action :set_session, only: [:new, :create]
  before_action :verify_host_or_guest, only: [:new, :create]


  def new
  end

  def create
  end


  private

  def set_session
    @session = GameSession.find_by!(uuid: params[:uuid])
  end

end
