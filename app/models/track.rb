class Track < ApplicationRecord
  has_and_belongs_to_many :playlists

  ##
  # Given a Spotify track returned from the Spotify API, returns a Track record to represent the track.
  #
  # If a Track record for the Spotify track already exists in the database, the existing Track is returned and its attributes are updated with the values returned by the API (passed in as +spotify_track+ and, optionally, +spotify_audio_features+). The new values ARE NOT SAVED to the database.
  #
  # If no Track record for the Spotify track exists in the database, a new one is created and initialized with values from the API (passed in as +spotify_track+ and, optionally, +spotify_audio_features+). The new record is not persisted to the database.
  #
  # @param [RSpotify:Track] spotify_track A Spotify Track object returned by the Spotify API
  # @param [RSpotify:AudioFeatures] spotify_audio_features The Spotify Audio Features object associated with +spotify_track+
  #
  # @return [Track]
  def self.new_from_spotify_track(spotify_track, spotify_audio_features=nil)
    track = Track.find_or_initialize_by(spotify_id: spotify_track.id)

    track.attributes = {
      name: spotify_track.name,
      artist: spotify_track.artists[0].name,
      album: spotify_track.album.name,
      image: spotify_track.album.images[0]["url"],
      preview: spotify_track.preview_url
    }
    
    track.valence = spotify_audio_features.valence if spotify_audio_features
    track
  end

  ##
  # Given a Spotify track returned from the Spotify API, returns a Track record to represent the track and ensures it is saved to the database.
  #
  # If a Track record for the Spotify track already exists in the database, the existing Track is returned and its attributes are updated with the values returned by the API (passed in as +spotify_track+ and +spotify_audio_features+). The new values ARE SAVED to the database.
  #
  # If no Track record for the Spotify track exists in the database, a new one is created with values from the API (passed in as +spotify_track+ and+spotify_audio_features+). The new record is persisted to the database.
  #
  # You must provide a +spotify_audio_features+ argument.
  #
  # @param [RSpotify:Track] spotify_track A Spotify Track object returned by the Spotify API
  # @param [RSpotify:AudioFeatures] spotify_audio_features The Spotify Audio Features object associated with +spotify_track+
  #
  # @return [Track]
  def self.create_from_spotify_track(spotify_track, spotify_audio_features)
    track = self.new_from_spotify_track(spotify_track, spotify_audio_features)
    track.save
    track
  end

  ##
  # Creates an array of Track records from an array of Spotify tracks.
  #
  # If no +spotify_audio_features+ argument is given, no valence will be recorded for the tracks.
  #
  # @param [Array<RSpotify:Track>] spotify_track An array of Spotify Track objects returned by the Spotify API
  # @param [Array<RSpotify:AudioFeatures>] spotify_audio_features An array of Spotify Audio Features objects associated with the +spotify_tracks+
  #
  # @return [Array<Track>]
  def self.new_from_spotify_tracks(spotify_tracks, spotify_audio_features=nil)
    spotify_tracks.map do |spotify_track|
      spotify_af_item =
        if spotify_audio_features
          spotify_audio_features.find { |item| item.id == spotify_track.id}
        else
          nil
        end
      self.new_from_spotify_track(spotify_track, spotify_af_item)
    end
  end

  ##
  # Creates an array of Track records from an array of Spotify tracks and audio features and saves each record to the database.
  #
  # You must provide a +spotify_audio_features+ argument.
  #
  # @param [Array<RSpotify:Track>] spotify_track An array of Spotify Track objects returned by the Spotify API
  # @param [Array<RSpotify:AudioFeatures>] spotify_audio_features An array of Spotify Audio Features objects associated with the +spotify_tracks+
  #
  # @return [Array<Track>]
  def self.create_from_spotify_tracks(spotify_tracks, spotify_audio_features)
    tracks = self.new_from_spotify_tracks(spotify_tracks, spotify_audio_features)
    tracks.each { |track| track.save }
    tracks
  end
end
