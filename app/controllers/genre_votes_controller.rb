class GenreVotesController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :set_session
  before_action :verify_host_or_guest
  before_action :prevent_double_voting, only: [:new, :create]

  def new
    @genre_vote = GenreVote.new
  end

  def create
    @genre_vote = GenreVote.new(genre_vote_params)
    @genre_vote.guest = current_guest_for_session

    if @genre_vote.save
      redirect_to genre_vote_path(@session.uuid, @genre_vote)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
     @genre_vote = GenreVote.find(params[:id])
  end

  private

  def genre_vote_params
    params.require(:genre_vote).permit(:genre_id)
  end

  def set_session
    @session = GameSession.find_by!(uuid: params[:uuid])
  end

  def prevent_double_voting
    @existing_genre_vote = GenreVote.find_by(guest: current_guest_for_session)
    redirect_to genre_vote_path(@session.uuid, @existing_genre_vote) if @existing_genre_vote
  end

end
