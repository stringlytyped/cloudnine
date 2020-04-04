class TracksController < ApplicationController
  def index
    @tracks = Track.all
    render json: @tracks
    @total = Track.all
  end

#  def top_100
#      s_tracks = RSpotify::Playlist.find("1276640268", "2kpoUUJ5a4Cw3feTkFJhZ2").tracks
#      @tracks = s_tracks.map do |s_track|
#        Track.new_from_spotify_track(s_track)
#      end
#  render json: @tracks
#  end

#  def random
#      s_tracks = RSpotify::Playlist.browse_featured.first.tracks
#      @total = s_tracks.map do |s_track|
#        if s_track.audio_features.valence > 0.6 && s_track.audio_features.valence < 0.7
#           s_track.audio_features.valence
#        end
#      end
#  render json: @total
#  end

  def av_val(playlist)
    s_tracks = playlist
    total_val = 0
    s_tracks.map do |s_track|
      total_val = total_val + s_track.audio_features.valence
    end
    @average = total_val/s_tracks.length
    return @average
  end

#  def new_playlist
#    s_tracks = RSpotify::Playlist.find("1276640268", "2kpoUUJ5a4Cw3feTkFJhZ2").tracks
#    av = av_val(s_tracks)
#    s_tracks = s_tracks.map do |s_track|
#      val = s_track.audio_features.valence
#      if val > av + 0.05 && val < av + 0.15
#         Track.new_from_spotify_track(s_track)
#      end
#    end
#    @tracks = s_tracks
#    render json: @tracks
#  end

#  def search
#    s_tracks = RSpotify::Track.search(params[:q])
#    @tracks = s_tracks.map do |s_track|
#        Track.new_from_spotify_track(s_track)
#    end
#  render json: @tracks
#  end

  def recommend
      playlist = RSpotify::Playlist.find("1276640268", '2kpoUUJ5a4Cw3feTkFJhZ2').tracks
      track_list = []
      track_list_test = playlist.map do |song|
        songs = Track.new_from_spotify_track(song).spotify_id
        track_list.push(songs)
      end
      av = av_val(playlist)
      min = av + 0.05
      max = av + 0.15
      seed_min = rand(track_list.length - 5)
      seed_max = seed_min + 4
      p seed_min
      recs = RSpotify::Recommendations.generate(limit: 10, seed_tracks: track_list[seed_min..seed_max], min_valence: min, max_valence: max)
      @tracks = recs
      render json: @tracks
    end
end
