class Song < ApplicationRecord
  belongs_to :genre
  has_many :session_songs
  has_many :song_votes, through: :session_songs, dependent: :destroy

  validates :title, presence: true
  validates :artist, presence: true

end
