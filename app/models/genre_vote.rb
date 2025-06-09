class GenreVote < ApplicationRecord
  belongs_to :guest
  belongs_to :genre

  validates :guest_id, uniqueness: true

  after_create_commit :broadcast_message

  private

  def broadcast_message
    broadcast_append_to "genre_stats_for_#{guest.game_session.id}",
                        partial: "game_sessions/genre_chart_stat",
                        target: "stats",
                        locals: { session: guest.game_session }
  end

end
