class SessionResetJob < ApplicationJob
  queue_as :default

  def perform(session_id)
    session = Session.find(session_id)

    # Only reset if still in sing_end stage
    return unless session.current_stage == 8

    session.transaction do
      # Clear voting data
      session.genre_votes.destroy_all
      session.song_votes.destroy_all

      # Return to green room
      session.update!(
        current_stage: 1,
        stage_started_at: Time.current,
        stage_data: {}
      )
    end

    # Broadcast reset
    SessionBroadcastService.new(session).broadcast_stage_change(1)
  end
end
