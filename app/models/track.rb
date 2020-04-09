class Track < ApplicationRecord
  has_and_belongs_to_many :playlists

  ##
  # Creates a new Track record to represent a Spotify track using data returned from the Spotify API.
  #
  # If no +spotify_audio_features+ argument is given, no valence will be recorded for the track.
  #
  # @param [RSpotify:Track] spotify_track A Spotify Track object returned by the Spotify API
  # @param [RSpotify:AudioFeatures] spotify_audio_features The Spotify Audio Features object associated with +spotify_track+
  #
  # @return [Track]
  def self.new_from_spotify_track(spotify_track, spotify_audio_features=nil)
    track =
      Track.new(
        spotify_id: spotify_track.id,
        name: spotify_track.name,
        artist: spotify_track.artists[0].name,
        album: spotify_track.album.name,
        image: spotify_track.album.images[0]["url"],
        preview: spotify_track.preview_url
      )
    
    track.valence = spotify_audio_features.valence if spotify_audio_features
    track
  end

  ##
  # Creates a new Track record to represent a Spotify track and saves it to the database.
  #
  # You must provide a +spotify_audio_features+ argument.
  #
  # @param [RSpotify:Track] spotify_track A Spotify Track object returned by the Spotify API
  # @param [RSpotify:AudioFeatures] spotify_audio_features The Spotify Audio Features object associated with +spotify_track+
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
