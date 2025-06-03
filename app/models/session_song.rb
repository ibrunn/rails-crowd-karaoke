class SessionSong < ApplicationRecord
  belongs_to :session
  belongs_to :song
end
