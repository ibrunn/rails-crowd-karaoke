class Guest < ApplicationRecord
  belongs_to :session

  has_many :song_votes
  has_many :genre_votes
end
