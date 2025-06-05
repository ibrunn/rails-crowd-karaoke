class Guest < ApplicationRecord
  belongs_to :game_session
  has_many :genre_votes, dependent: :destroy
  has_many :song_votes, dependent: :destroy

  before_validation :strip_and_titleize_nickname

  validates :nickname,
            presence: true,
            length: { in: 3..20 },
            format: { with: /\A[a-zA-Z0-9\s]+\z/,
            message: "only letters, numbers, and spaces allowed" }
  validates :nickname,
            uniqueness: {
              scope: :game_session_id,
              message: "is already taken in this session" }


  private

  # data cleaning method that ensures consistent spacing in user input
  def strip_and_titleize_nickname
    self.nickname = nickname.to_s.strip.squeeze(' ') if nickname.present?
  end

end
