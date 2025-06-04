class Guest < ApplicationRecord
  belongs_to :session
  has_many :song_votes
  has_many :genre_votes

  validates :nickname, presence: true,
    length: { in: 3..20 },
    format: { with: /\A[a-zA-Z0-9\s]+\z/ }
  validates :nickname, uniqueness: { scope: :session_id }

end
