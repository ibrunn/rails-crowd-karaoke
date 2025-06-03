class Song < ApplicationRecord
  belongs_to :genre
  has_many :session_songs

end
