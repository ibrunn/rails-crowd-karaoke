class AddSessionSongToSongVotes < ActiveRecord::Migration[7.1]
  def change
    add_reference :song_votes, :session_song, null: false, foreign_key: true
  end
end
