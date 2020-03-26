class TracksController < ApplicationController
  def index
    @tracks = Track.all
    render json: @tracks
    @total = Track.all
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
      @total = s_tracks.map do |s_track|
        if s_track.audio_features.valence > 0.6 && s_track.audio_features.valence < 0.7
           Track.new_from_spotify_track(s_track)
        end
      end
  render json: @total
  end

  def search
    s_tracks = RSpotify::Track.search(params[:q])
    @tracks = s_tracks.map do |s_track|
        Track.new_from_spotify_track(s_track)
    end
  render json: @tracks
  end
end
