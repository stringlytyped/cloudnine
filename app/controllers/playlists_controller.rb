class PlaylistsController < ApplicationController
  before_action :authenticate_user!
  before_action :show_start_page

  def show_mine
    @playlist = current_user.playlist
    @location = current_user.location

    # Ensure user token is valid to allow playback using the Spotify Web Playback SDK
    current_user.refresh_token
    # Update weather data for view and for target valence calculation
    @location.update_weather_data if @location

    @playlist.populate(current_user.target_valence, 30) if @playlist.size == 0
    
    render :show_mine
  end

  def refresh
    # Update weather data for target valence calculation
    current_user.location.update_weather_data if current_user.location

    current_user.playlist.repopulate(current_user.target_valence, 30)
    redirect_to playlist_path
  end

  private

  def show_start_page
    redirect_to start_path if current_user.privacy_consent_needed? ||
                              !current_user.location ||
                              current_user.time_since_last_mood_rating > 12.hours
  end
end
