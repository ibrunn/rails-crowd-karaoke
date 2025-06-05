class SessionResetJob < ApplicationJob
  queue_as :default

  def perform(game_session_id)
    game_session = Session.find(game_session_id)

    # Only reset if still in sing_end stage
    return unless game_session.current_stage == 8

    game_session.transaction do
      # Clear voting data
      game_session.genre_votes.destroy_all
      game_session.song_votes.destroy_all

      # Return to green room
      game_session.update!(
        current_stage: 1,
        stage_started_at: Time.current,
        stage_data: {}
      )
    end

    # Broadcast reset
    SessionBroadcastService.new(game_session).broadcast_stage_change(1)
  end
end
