class PlaylistsController < ApplicationController
  before_action :authenticate_user!

  def show_mine
    @playlist = current_user.playlist
    @location = current_user.location

    # Ensure user token is valid to allow playback using the Spotify Web Playback SDK
    current_user.refresh_token
    # Update weather data for view and for target valence calculation
    @location.update_weather_data if @location

    @playlist.populate(target_valence, 30) if @playlist.size == 0
    
    render :show_mine
  end

  def refresh
    # Update weather data for target valence calculation
    current_user.location.update_weather_data if current_user.location

    current_user.playlist.repopulate(target_valence, 30)
    redirect_to playlist_path
  end

  private

  ##
  # Calculates the target valence for the current user, factoring in the user's most recent mood rating and the current weather conditions.
  #
  # The target is boosted depending on the weather. E.g. if it is raining, 0.08 is added to the target valence. If no location is set for the user, a default term of 0.04 is added. The maximum term added to adjust for the weather is 0.08.
  #
  # Similiarly, a boost is applied depending on the user's last mood rating. If the user's last mood rating was more than 12 hours ago, or if the user never rated their mood, a default term of 0.075 is added. The maximum term added to adjust for the user's mood is 0.15.
  #
  # @return [Float]
  def target_valence
    condition_id = current_user.location ? current_user.location.condition_id : nil

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

    last_mood_rating = MoodRating.where(user_id: current_user.id)
                                 .order(id: :desc).limit(1).first
    
    time_diff = last_mood_rating ? Time.now - last_mood_rating.created_at : 50_000

    mood_term =
      if time_diff <= 43_200 # 12 hours
        (1 - last_mood_rating.value) * 0.15
        # Happy:   0
        # Neutral: 0.075
        # Sad:     0.15
      else
        # If last mood rating for more than 12 hours ago assume neutral mood
        0.075
      end
    
    (current_user.valence_baseline + weather_term + mood_term).clamp(0, 1)
  end
end
