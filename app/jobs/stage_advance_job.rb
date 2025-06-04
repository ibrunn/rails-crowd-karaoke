class StageAdvanceJob < ApplicationJob
  queue_as :default

  def perform(session_id)
    session = Session.find(session_id)
    return unless session.should_auto_advance?

    # Advance to next stage
    next_stage = session.calculate_next_stage
    session.update!(
      current_stage: next_stage,
      stage_started_at: Time.current
    )

    # Broadcast changes via Turbo Streams
    SessionBroadcastService.new(session).broadcast_stage_change
  end
end
