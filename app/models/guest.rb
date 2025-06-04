class Guest < ApplicationRecord
  belongs_to :session
  has_many :genre_votes, dependent: :destroy
  has_many :song_votes, dependent: :destroy

  validates :nickname, presence: true,
    length: { in: 3..20 },
    format: { with: /\A[a-zA-Z0-9\s]+\z/,
              message: "only letters, numbers, and spaces allowed" }
  validates :nickname, uniqueness: { scope: :session_id,
                                     message: "is already taken in this session" }

                                       before_validation :strip_and_titleize_nickname

  private

  def strip_and_titleize_nickname
    self.nickname = nickname.to_s.strip.squeeze(' ') if nickname.present?
  end
  
end
