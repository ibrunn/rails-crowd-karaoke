class SongVote < ApplicationRecord
  belongs_to :guest
  belongs_to :game_session_song

  validates :guest_id, uniqueness: { scope: :game_session_song_id,
                                      message: "Record already exists - use increment instead" }

  # Ensure votes_count is always positive
  validates :votes_count,
            presence: true,
            numericality: { greater_than: 0 }

  # Custom validation to ensure guest belongs to the same session
  validate :guest_belongs_to_session

  # Default value for votes_count
  after_initialize :set_default_votes_count, if: :new_record?

  private

  def set_default_votes_count
    self.votes_count ||= 1
  end

  def guest_belongs_to_session
    return unless guest && game_session_song

    unless guest.game_session == game_session_song.game_session
      errors.add(:guest, "must belong to the same session")
    end
  end
end
