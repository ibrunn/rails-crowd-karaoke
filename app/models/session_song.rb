class SessionSong < ApplicationRecord
  belongs_to :session
  belongs_to :song
  has_many :song_votes

end
