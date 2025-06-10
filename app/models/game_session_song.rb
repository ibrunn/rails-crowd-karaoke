class GameSessionSong < ApplicationRecord
  belongs_to :game_session
  belongs_to :song

  has_many :song_votes, dependent: :destroy

  # Method to display song info in the form
  def song_display_name
    "#{song.title} - #{song.artist}"
  end

  # Alternative method with more details
  def song_display_name_with_year
    "#{song.title} - #{song.artist} (#{song.year})"
  end

end
