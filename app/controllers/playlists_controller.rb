class PlaylistsController < ApplicationController
  # load_and_authorize_resource
  before_action :set_playlist, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, except: [:index, :show]

  def show_mine
    @playlist = current_user.playlist
    @location = current_user.location

    @playlist.populate(0.5, 30) if @playlist.size == 0
    @location.update_weather_data if @location
    
    render :show
  end
  
  def index
    @playlists = Playlist.all
  end

  def show
  end

  def new
    @playlist = Playlist.new
  end

  def edit
  end

  def create
    @playlist = Playlist.new(playlist_params)
    @playlist.user = current_user
    if @playlist.save
      redirect_to @playlist, notice: 'Playlist was successfully created.'
    else
      render :new
    end
  end

  def update
    if @playlist.update(playlist_params)
      redirect_to @playlist, notice: 'Playlist was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @playlist.destroy
    redirect_to playlists_url, notice: 'Playlist was successfully destroyed.'
  end

  private
  def set_playlist
    @playlist = Playlist.find(params[:id])
  end

  def playlist_params
    params.require(:playlist).permit(:name, :rating)
  end
end