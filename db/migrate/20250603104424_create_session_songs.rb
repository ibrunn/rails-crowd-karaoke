class CreateSessionSongs < ActiveRecord::Migration[7.1]
  def change
    create_table :session_songs do |t|
      t.references :session, null: false, foreign_key: true
      t.references :song, null: false, foreign_key: true

      t.timestamps
    end
  end
end
