class CreatePlaylistsAndTracks < ActiveRecord::Migration[6.0]
  def change
    create_table :playlists do |t|
      t.integer :user_id
      t.string :name
      t.string :spotify_id

      t.timestamps
    end

    create_table :tracks do |t|
      t.string :name
      t.string :artist
      t.string :album
      t.string :image
      t.string :preview
      t.float :valence
      t.string :spotify_id

      t.timestamps
    end

    create_table :playlists_tracks, id: false do |t|
      t.references :playlist
      t.references :track
    end

    add_index :playlists, :user_id, unique: true
    add_index :tracks, :spotify_id, unique: true
  end
end
