class SongVote < ApplicationRecord
  belongs_to :guest
  belongs_to :song
  belongs_to :session
end
