class GenreVote < ApplicationRecord
  belongs_to :guest
  belongs_to :genre
  
end
