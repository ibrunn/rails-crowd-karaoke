class GameSessionSong < ApplicationRecord
  belongs_to :game_session
  belongs_to :song
  has_many :song_votes

end
