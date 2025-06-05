class StageAdvanceJob < ApplicationJob
  queue_as :default

  def perform(game_session_id)
    game_session = GameSession.find(game_session_id)
    return unless game_session.should_auto_advance?

    # Advance to next stage
    next_stage = game_session.calculate_next_stage
    game_session.update!(
      current_stage: next_stage,
      stage_started_at: Time.current
    )

    # Broadcast changes via Turbo Streams
    SessionBroadcastService.new(game_session).broadcast_stage_change
  end
end
