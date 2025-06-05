class GameSession < ApplicationRecord
  belongs_to :user
  has_many :game_session_songs, dependent: :destroy
  has_many :songs, through: :game_session_songs
  has_many :guests, dependent: :destroy
  has_many :genre_votes, through: :guests
  has_many :song_votes, through: :guests

  before_validation :generate_uuid

  validates :uuid, presence: true, uniqueness: true
  validates :current_stage, presence: true,
            inclusion: { in: [0, 1, 2, 3, 3.5, 4, 5, 5.5, 6, 7, 8] }

  private

  def generate_uuid
    self.uuid = SecureRandom.uuid
  end

end
