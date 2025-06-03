class Session < ApplicationRecord
  belongs_to :user


  has_many :session_songs
  has_many :songs, through: :session_songs
  has_many :guests
  has_many :genre_votes, through: :guests
  has_many :song_votes, through: :guests
end
