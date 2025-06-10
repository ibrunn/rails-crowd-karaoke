class AddColumnToGenres < ActiveRecord::Migration[7.1]
  def change
    add_column :genres, :slug, :string
  end
end
