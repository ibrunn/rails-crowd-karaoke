class SongVotesController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :set_session
  before_action :verify_host_or_guest


  def new
    @song_vote = SongVote.new
  end

  def create
    @song_vote = SongVote.new(song_vote_params)
    @song_vote.guest = current_guest_for_session

    if @song_vote.save
      # redirect_to song_vote_path(@session.uuid, @song_vote)
    else
      render :new, status: :unprocessable_entity
    end
  end


  private

  def song_vote_params
    params.require(:song_vote).permit(:game_session_song_id)
  end

  def set_session
    @session = GameSession.find_by!(uuid: params[:uuid])
  end

end
