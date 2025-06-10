class SongVotesController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :set_session
  before_action :verify_host_or_guest
  before_action :verify_guest_access
  before_action :verify_voting_stage


  def new
    @song_vote = SongVote.new
    # Show current vote counts for this guest
    @guest_votes = current_guest_vote_counts
  end

  def create
    game_session_song_id = song_vote_params[:game_session_song_id]

    # Find existing vote or create new one
    @song_vote = SongVote.find_or_initialize_by(
      guest: current_guest_for_session,
      game_session_song_id: game_session_song_id
    )

    if @song_vote.persisted?
      # Increment existing vote count
      @song_vote.increment!(:votes_count)
      message = "Vote added! You've voted #{@song_vote.votes_count} times for this song."
    else
      # Create new vote with count of 1
      @song_vote.votes_count = 1
      if @song_vote.save
        message = "First vote recorded for this song!"
      else
        render :new, status: :unprocessable_entity
        return
      end
    end

    # Broadcast vote count update
    broadcast_vote_update

    # Return to voting form with updated counts (AJAX response)
    respond_to do |format|
      format.html {
        redirect_to new_song_votes_path(@session.uuid), notice: message
      }
      format.json {
        render json: {
          success: true,
          message: message,
          vote_count: @song_vote.votes_count,
          total_votes: current_guest_total_votes
        }
      }
    end

  end


  private

  def song_vote_params
    params.require(:song_vote).permit(:game_session_song_id)
  end

  def set_session
    @session = GameSession.find_by!(uuid: params[:uuid])
  end

  def verify_guest_access
    unless current_guest_for_session
      redirect_to new_guest_path(@session.uuid), alert: "Please join the session first."
    end
  end

  def verify_voting_stage
    unless @session.current_stage == 5.0  # Song voting stage
      redirect_to get_stage_destination(@session.current_stage, :guest, @session),
                  alert: "Song voting is not currently active."
    end
  end

  def current_guest_vote_counts
    # Get vote counts for current guest for this session's songs
    SongVote.joins(:game_session_song)
            .where(
              guest: current_guest_for_session,
              game_session_songs: { game_session: @session }
            )
            .includes(game_session_song: :song)
            .index_by(&:game_session_song_id)
  end

  def current_guest_total_votes
    current_guest_vote_counts.values.sum(&:votes_count)
  end

  def broadcast_vote_update
    # Update vote counts on host's screen
    Turbo::StreamsChannel.broadcast_update_to(
      "game_session_#{@session.uuid}_host",
      target: "vote-counts",
      partial: "game_sessions/song_chart_stat",
      locals: { session: @session }
    )

  #   # Update guest voting status
  #   Turbo::StreamsChannel.broadcast_update_to(
  #     "game_session_#{@session.uuid}_guest",
  #     target: "voting-status",
  #     partial: "song_votes/voting_status",
  #     locals: { session: @session }
  #   )
  end
end
