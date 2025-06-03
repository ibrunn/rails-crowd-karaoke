class CreateGenreVotes < ActiveRecord::Migration[7.1]
  def change
    create_table :genre_votes do |t|
      t.references :guest, null: false, foreign_key: true
      t.references :genre, null: false, foreign_key: true

      t.timestamps
    end
  end
end
