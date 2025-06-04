class GenreVotesController < ApplicationController
  def broadcast_votes
    genre_counts = Vote.group(:genre).count
    data = genre_counts.map do |genre, count|
      {
        label: genre,
        value: count,
        color: genre_color_map[genre] || "#333"
      }
    end
    ActionCable.server.broadcast("votes", data)
  end
end
