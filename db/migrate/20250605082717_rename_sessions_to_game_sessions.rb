class RenameSessionsToGameSessions < ActiveRecord::Migration[7.1]
  # Generate the migration:
  # rails generate migration RenameSessionsToGameSessions

    def up
      # Step 1: Rename the table
      rename_table :sessions, :game_sessions

      # Step 2: Update foreign key columns in related tables
      rename_column :guests, :session_id, :game_session_id
      rename_column :session_songs, :session_id, :game_session_id

      # Step 3: Rename the session_songs table to game_session_songs
      rename_table :session_songs, :game_session_songs

      # Step 4: Update foreign key references in votes tables
      # Note: These reference session_songs which is now game_session_songs
      rename_column :song_votes, :session_song_id, :game_session_song_id

      # Step 5: Update any indexes that reference the old table name
      # Rails will automatically handle most indexes, but check for custom ones

      # Step 6: Update foreign key constraints if you have them explicitly defined
      if foreign_key_exists?(:guests, :sessions)
        remove_foreign_key :guests, :sessions
        add_foreign_key :guests, :game_sessions
      end

      if foreign_key_exists?(:game_session_songs, :sessions)
        remove_foreign_key :game_session_songs, :sessions
        add_foreign_key :game_session_songs, :game_sessions
      end

      if foreign_key_exists?(:song_votes, :session_songs)
        remove_foreign_key :song_votes, :session_songs
        add_foreign_key :song_votes, :game_session_songs
      end
    end

    def down
      # Reverse all the changes for rollback

      # Remove new foreign keys
      remove_foreign_key :guests, :game_sessions if foreign_key_exists?(:guests, :game_sessions)
      remove_foreign_key :game_session_songs, :game_sessions if foreign_key_exists?(:game_session_songs, :game_sessions)
      remove_foreign_key :song_votes, :game_session_songs if foreign_key_exists?(:song_votes, :game_session_songs)

      # Restore old foreign keys
      add_foreign_key :guests, :sessions if table_exists?(:sessions)
      add_foreign_key :session_songs, :sessions if table_exists?(:sessions) && table_exists?(:session_songs)
      add_foreign_key :song_votes, :session_songs if table_exists?(:session_songs)

      # Rename columns back
      rename_column :song_votes, :game_session_song_id, :session_song_id
      rename_table :game_session_songs, :session_songs
      rename_column :guests, :game_session_id, :session_id
      rename_column :session_songs, :game_session_id, :session_id

      # Rename main table back
      rename_table :game_sessions, :sessions
    end
end
