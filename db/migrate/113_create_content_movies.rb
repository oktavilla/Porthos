class CreateContentMovies < ActiveRecord::Migration
  def self.up
    create_table :content_movies, :force => true do |t|
      t.integer     :movie_asset_id
      t.string      :title
      t.text        :caption
      t.string      :copyright
      t.timestamps
    end
    add_index :content_movies, :movie_asset_id
  end

  def self.down
    drop_table :content_movies
  end
end
