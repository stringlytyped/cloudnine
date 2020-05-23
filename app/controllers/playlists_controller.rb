class PlaylistsController < ApplicationController
  before_action :authenticate_user!

  def show_mine
    @playlist = current_user.playlist
    @location = current_user.location

    # Ensure user token is valid to allow playback using the Spotify Web Playback SDK
    current_user.refresh_token

    @playlist.populate(0.5, 30) if @playlist.size == 0
    @location.update_weather_data if @location
    
    render :show_mine
  end

  def refresh
    playlist = current_user.playlist
    playlist.repopulate(0.5, 30)
    redirect_to playlist_path
  end
end
