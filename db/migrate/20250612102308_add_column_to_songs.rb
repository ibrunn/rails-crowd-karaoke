class AddColumnToSongs < ActiveRecord::Migration[7.1]
  def change
    add_column :songs, :album_url, :string
  end
end
