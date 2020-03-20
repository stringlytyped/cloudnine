class TracksController < ApplicationController
  def index
    @tracks = Track.all
    render json: @tracks
  end

  def top_100
      s_tracks = RSpotify::Playlist.find("1276640268", "2kpoUUJ5a4Cw3feTkFJhZ2").tracks
      @tracks = s_tracks.map do |s_track|
        Track.new_from_spotify_track(s_track)
      end
  render json: @tracks
  end

  def random
      s_tracks = RSpotify::Playlist.browse_featured.first.tracks
      @tracks = s_tracks.map do |s_track|
          Track.new_from_spotify_track(s_track)
      end
  render json: @tracks
  end

  def search
    s_tracks = RSpotify::Track.search(params[:q])
    @tracks = s_tracks.map do |s_track|
        Track.new_from_spotify_track(s_track)
    end
  render json: @tracks
  end
end
