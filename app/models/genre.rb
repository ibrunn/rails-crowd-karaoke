class Genre < ApplicationRecord
  has_many :songs
  has_many :genre_votes

end
