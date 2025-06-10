class Song < ApplicationRecord
  belongs_to :genre
  has_many :game_session_songs
  has_many :song_votes, through: :game_session_songs, dependent: :destroy

  validates :title, presence: true
  validates :artist, presence: true

end
