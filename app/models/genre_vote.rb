class GenreVote < ApplicationRecord
  belongs_to :guest
  belongs_to :genre

  validates :guest_id, uniqueness: true

end
