require "rqrcode"
class GameSessionsController < ApplicationController
  before_action :authenticate_user!, except: [:green_room, :genre_start, :genre_result,
                                              :song_start, :song_result, :sing_start, :sing_end, :singing,
                                              :start_game, :advance_to_stage, :advance_stage_handler]
  before_action :set_session, only: [:show, :green_room, :genre_start, :genre_result,
                                     :song_start, :song_result, :sing_start, :sing_end, :singing,
                                     :start_game, :advance_to_stage, :advance_stage_handler, :genre_stats, :song_stats]
  before_action :verify_host_or_guest, only: [:show, :green_room, :genre_start, :genre_result,
                                              :song_start, :song_result, :sing_start, :sing_end, :singing,
                                              :start_game, :advance_to_stage, :advance_stage_handler, :song_stats]

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

  def genre_stats
  end

  def genre_result
    # 1. Determine the winning genre for the current session
    @winning_genre = find_winning_genre

    # 2. Pick 4 random songs from the winning genre and store them
    if @winning_genre
      store_session_songs(@winning_genre)
    else
      # Fallback: pick a random genre if no votes exist
      @winning_genre = Genre.order('RANDOM()').first
      store_session_songs(@winning_genre) if @winning_genre
    end
  end

  def song_start
  end

  def song_stats
  end

  def song_result
    # Determine the winning song for the current session
    @winning_song = find_winning_song

    if @winning_song
      Rails.logger.info "Winning song: '#{@winning_song.title}' by #{@winning_song.artist}"
    else
      Rails.logger.info "No votes cast for songs"
    end
  end

  def sing_start
    @winning_song = find_winning_song
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

    # In case of multiple rounds, delete session records in the tables:
    # game_session_songs, song_votes, genre_votes
    # only clean records belonging to this very @session
    @session.game_session_songs.destroy_all
    GenreVote.joins(:guest).where(guests: { game_session: @session }).destroy_all

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

    # Broadcast to hosts using Turbo.visit (works in all Rails versions)
    Turbo::StreamsChannel.broadcast_update_to(
      "game_session_#{@session.uuid}_host",
      action: "append",
      target: "head",
      html: %(<script>
        setTimeout(() => {
          Turbo.visit("#{host_destination}");
        }, 100);
      </script>)
    )

    # Broadcast to guests using Turbo.visit
    Turbo::StreamsChannel.broadcast_update_to(
      "game_session_#{@session.uuid}_guest",
      action: "append",
      target: "head",
      html: %(<script>
        setTimeout(() => {
          Turbo.visit("#{guest_destination}");
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
    auto_stages = [3.0, 35.0, 4.0, 5.0, 55.0, 8.0]
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
      3.0 => [35.0],   # Genre voting → Genre result
      35.0 => [4.0],   # Genre result → Song start
      4.0 => [5.0],   # Song start → Song voting
      5.0 => [55.0],   # Song voting → Song result
      55.0 => [6.0],   # Song result → Sing start
      6.0 => [1.0],   # Sing start → Singing
    }

    valid_transitions[current]&.include?(new)
  end

  def find_winning_genre
    # Get all guests for this session
    guest_ids = @session.guests.pluck(:id)

    # Return nil if no guests
    return nil if guest_ids.empty?

    # Find the genre with the most votes from this session's guests
    Genre.joins(:genre_votes)
        .where(genre_votes: { guest_id: guest_ids })
        .group('genres.id')
        .order('COUNT(genre_votes.id) DESC')
        .first
  end

  def store_session_songs(genre)
    return unless @session.user == current_user

    # Clear any existing songs for this session
    @session.game_session_songs.destroy_all

    # Get 4 random songs from the winning genre
    selected_songs = genre.songs.order('RANDOM()').limit(4)

    # Create game_session_songs records
    selected_songs.each do |song|
      @session.game_session_songs.create!(song: song)
    end

    # Make selected songs accessible to the view
    @selected_songs = selected_songs

    Rails.logger.info "Selected #{selected_songs.count} songs from genre '#{genre.name}' for session #{@session.uuid}"
  end

  def find_winning_song
    # Get all guests for this session
    guest_ids = @session.guests.pluck(:id)

    # Return nil if no guests
    return nil if guest_ids.empty?

    # Find the game_session_song with the highest total votes from this session's guests
    winning_game_session_song = @session.game_session_songs
                                      .joins(:song_votes)
                                      .where(song_votes: { guest_id: guest_ids })
                                      .group('game_session_songs.id')
                                      .order('SUM(song_votes.votes_count) DESC')
                                      .includes(:song)
                                      .first

    # Return the actual Song instance (not GameSessionSong)
    winning_game_session_song&.song
  end

end
