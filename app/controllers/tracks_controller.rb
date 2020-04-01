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
           s_track.audio_features.valence
        end
      end
  render json: @total
  end

  def av_val
    s_tracks = RSpotify::Playlist.find("1276640268", "2kpoUUJ5a4Cw3feTkFJhZ2").tracks
    total_val = 0
    av = s_tracks.length
    s_tracks.map do |s_track|
      total_val = total_val + s_track.audio_features.valence
    end
    @average = total_val/s_tracks.length
    return @average
  end

  def new_playlist
    s_tracks = RSpotify::Playlist.find("1276640268", "2kpoUUJ5a4Cw3feTkFJhZ2").tracks
    av = av_val
    s_tracks = s_tracks.map do |s_track|
      if s_track.audio_features.valence > av + 0.05 && s_track.audio_features.valence < av + 0.15
         Track.new_from_spotify_track(s_track)
      end
    end
    @tracks = s_tracks
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
