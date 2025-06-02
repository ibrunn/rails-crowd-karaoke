class CreateSongs < ActiveRecord::Migration[7.1]
  def change
    create_table :songs do |t|
      t.string :title
      t.string :artist
      t.integer :year
      t.text :lyrics_lrc
      t.string :youtube_url
      t.references :genre, null: false, foreign_key: true

      t.timestamps
    end
  end
end
