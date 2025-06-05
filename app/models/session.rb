class Session < ApplicationRecord
  belongs_to :user
  before_create :generate_uuid
  has_many :session_songs, dependent: :destroy
  has_many :songs, through: :session_songs
  has_many :guests, dependent: :destroy
  has_many :genre_votes, through: :guests
  has_many :song_votes, through: :guests

  # validates :uuid, presence: true, uniqueness: true





  private

  def generate_uuid
    self.uuid = SecureRandom.uuid
  end

end
