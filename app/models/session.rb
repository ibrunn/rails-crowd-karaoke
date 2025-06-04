class Session < ApplicationRecord
  belongs_to :user
  has_many :session_songs, dependent: :destroy
  has_many :songs, through: :session_songs
  has_many :guests, dependent: :destroy
  has_many :genre_votes, through: :guests
  has_many :song_votes, through: :guests

  validates :uuid, presence: true, uniqueness: true
  validates :current_stage, presence: true,
            inclusion: { in: [0, 1, 2, 3, 3.5, 4, 5, 5.5, 6, 7, 8] }

  before_create :generate_uuid
  serialize :stage_data, JSON

  # Helper methods for stage management
  def in_voting_stage?
    [3, 5].include?(current_stage)
  end

  def auto_advance_stage?
    [2, 3.5, 4, 5.5, 6, 8].include?(current_stage)
  end

  def can_return_to_stage?
    # Always allow return to last current stage
    true
  end

  private

  def generate_uuid
    self.uuid = SecureRandom.uuid
  end

end
