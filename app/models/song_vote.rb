class SongVote < ApplicationRecord
  belongs_to :guest
  belongs_to :session_song
  
end
