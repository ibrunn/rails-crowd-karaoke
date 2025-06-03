class CreateSongVotes < ActiveRecord::Migration[7.1]
  def change
    create_table :song_votes do |t|
      t.references :guest, null: false, foreign_key: true
      t.integer :votes_count

      t.timestamps
    end
  end
end
