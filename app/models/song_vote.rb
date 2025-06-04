class SongVote < ApplicationRecord
  belongs_to :guest
  belongs_to :session_song

  validates :guest_id, uniqueness: { scope: :session_song_id,
            message: "no multiple records of the same guest/song combination, # of votes are updated in votes_count" }

end
