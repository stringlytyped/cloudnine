require 'json'

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :omniauthable, omniauth_providers: %i[spotify]
  rolify
  
  has_one :playlist, dependent: :destroy
  has_one :location
  has_many :mood_ratings, dependent: :destroy

  before_create :build_default_playlist

  def admin?
    has_role?(:admin)
  end

  def standard?
    has_role?(:standard)
  end

  ##
  # Returns the user's OAuth credentials as a Hash which can be used to authorize requests to the Spotify API.
  #
  # @return [Hash]
  def credentials
    JSON.parse(self.credentials_json)
  end

  ##
  # Converts the User object to a RSpotify user so that it can be used to issue requests to the Spotify API.
  #
  # @return [RSpotify::User]
  def to_rspotify_user
    RSpotify::User.new({"credentials" => self.credentials})
  end

  ##
  # Fetches 5 random tracks from the user's top Spotify tracks. User must be authenticated.
  #
  # @return [Array<Track>]
  def random_top_tracks
    spotify_user = self.to_rspotify_user
    spotify_top_tracks = spotify_user.top_tracks(limit: 50)
    spotify_random_tracks = spotify_top_tracks.sample(5)
    spotify_random_tracks.map { |spotify_track| Track.new_from_spotify_track(spotify_track) }
  end

  ##
  # Fetches 100 recommended tracks for the user based on their listening history. User must be authenticated.
  #
  # If +target_valence+ is provided, the returned tracks will be limited to those with valence values within ± 0.25.
  #
  # @param [Float] target_valence The valence that the returned tracks should be near
  #
  # @return [Array<Track>]
  def recommended_tracks(target_valence=nil)
    if target_valence
      max_valence = target_valence + 0.25
      min_valence = target_valence - 0.25
      
      max_valence = 1 if max_valence > 1
      min_valence = 0 if min_valence < 0
    else
      max_valence = 1; min_valence = 0
    end

    seed_track_ids = self.random_top_tracks.map { |track| track.spotify_id }

    spotify_tracks = 
      RSpotify::Recommendations.generate(
        limit: 100,
        seed_tracks: seed_track_ids,
        max_valence: max_valence,
        min_valence: min_valence
      ).tracks

    track_ids = spotify_tracks.map { |spotify_track| spotify_track.id }
    audio_features_objects = RSpotify::AudioFeatures.find(track_ids)

    Track.new_from_spotify_tracks(spotify_tracks, audio_features_objects)
  end

  ##
  # Given an OmniAuth authentication hash, finds and returns the relevant User record.
  # If the User does not exist in the database, a new User record is created and returned.
  #
  # The OAuth credentials used to authorize future requests to the Spotify API are converted to JSON and stored in the +credentials_json+ field.
  #
  # Adapted from the Devise OmniAuth guide: https://github.com/heartcombo/devise/wiki/OmniAuth:-Overview
  #
  # @param [Hash] auth The OmniAuth authentication hash obtained from +request.env['omniauth.auth']+
  #
  # @return [User]
  def self.from_omniauth(auth)
    user = where(provider: auth.provider, uid: auth.uid).first_or_create
    # Can pass a block to first_or_create to set additional database fields from the data provided by Spotify (e.g. the user's email address) but we must comply with the Spotify Developer TOS which prohibits long-term storage of data

    spotify_user = RSpotify::User.new(auth)
    credentials_json = spotify_user.to_hash["credentials"].to_json
    user.credentials_json = credentials_json
    user.save

    user
  end

  private

  ##
  # Creates an empty Playlist object associated with the User.
  #
  # @return [true]
  def build_default_playlist
    build_playlist
    true
  end
end
