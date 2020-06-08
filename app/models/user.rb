require 'json'

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :omniauthable, omniauth_providers: %i[spotify]
  
  has_one :playlist, dependent: :destroy
  belongs_to :location, optional: true
  has_many :mood_ratings, dependent: :destroy

  before_create :build_default_playlist

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
  # Fetches a number of random tracks (defaults to 5) from the user's top Spotify tracks. User must be authenticated.
  #
  # If there is not sufficient listening history for the user, tracks from Spotify's Today's Top Hits playlist are returned instead of the user's top tracks.
  #
  # @param [Integer] quantity The number of tracks to attempt to return. May return fewer if greater than 0 or if the Spotify user does not have much listening history.
  #
  # @return [Array<Track>]
  def random_top_tracks(quantity=5)
    spotify_user = self.to_rspotify_user
    spotify_top_tracks = spotify_user.top_tracks(limit: 50)

    if spotify_top_tracks.length == 0
      spotify_top_tracks = RSpotify::Playlist.find("spotify", "37i9dQZF1DXcBWIGoYBM5M").tracks
    end

    spotify_random_tracks = spotify_top_tracks.sample(quantity)
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
      max_valence = (target_valence + 0.25).clamp(0, 1)
      min_valence = (target_valence - 0.25).clamp(0, 1)
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
  # Calculates a baseline valence value for the user based on their listening history by finding the average valence of the user's top 50 tracks.
  #
  # @return [Float]
  def valence_baseline
    top_tracks = random_top_tracks(50)
    top_track_ids = top_tracks.map { |track| track.spotify_id }
    audio_features_objects = RSpotify::AudioFeatures.find(top_track_ids)

    total_valence = audio_features_objects.reduce(0) { |sum, n| sum + n.valence } 
    total_valence / audio_features_objects.length
  end

  ##
  # Calculates the target valence for the user, factoring in the user's most recent mood rating and the current weather conditions.
  #
  # The target is boosted depending on the weather. E.g. if it is raining, 0.08 is added to the target valence. If no location is set for the user, a default term of 0.04 is added. The maximum term added to adjust for the weather is 0.08.
  #
  # Similiarly, a boost is applied depending on the user's last mood rating. If the user's last mood rating was more than 12 hours ago, or if the user never rated their mood, a default term of 0.075 is added. The maximum term added to adjust for the user's mood is 0.15.
  #
  # @return [Float]
  def target_valence
    condition_id = location ? location.condition_id : nil

    weather_term = 
      case condition_id
      when "800"       # Clear
        0
      when /6\d\d/     # Snowing
        0
      when /8\d\d/     # Cloudy
        0.04
      when /7\d\d/     # Foggy
        0.08
      when /[235]\d\d/ # Raining
        0.08
      else             # Any invalid code
        0.04
      end

    mood_term =
      if time_since_last_mood_rating <= 12.hours
        (1 - last_mood_rating.value) * 0.15
        # Happy:   0
        # Neutral: 0.075
        # Sad:     0.15
      else
        # If last mood rating for more than 12 hours ago assume neutral mood
        0.075
      end
    
    (valence_baseline + weather_term + mood_term).clamp(0, 1)
  end

  ##
  # Refreshes the OAuth token for the user.
  #
  # @return [nil]
  def refresh_token
    spotify_user = self.to_rspotify_user

    # Issue any request to the Spotify API to trigger a token refresh
    spotify_user.recently_played(limit: 1)

    # Save new token
    credentials_json = spotify_user.to_hash["credentials"].to_json
    self.credentials_json = credentials_json
    nil
  end

  def privacy_consent_needed?
    !privacy_consent_at
  end

  def last_mood_rating
    MoodRating.where(user_id: id).order(id: :desc).limit(1).first
  end

  def time_since_last_mood_rating
    last_mood_rating ? Time.now - last_mood_rating.created_at : Float::INFINITY
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
