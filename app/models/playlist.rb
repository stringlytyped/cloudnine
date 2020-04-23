class Playlist < ApplicationRecord
  belongs_to :user
  has_and_belongs_to_many :tracks

  ##
  # Returns the number of tracks in the playlist
  #
  # @return [Integer]
  def size
    tracks.size
  end

  ##
  # Calculates the average valence of the tracks in the playlist
  #
  # @return [Float]
  def avg_valence
    total_valence = self.tracks.reduce(0) { |sum, track| sum + track.valence }
    total_valence / self.tracks.length
  end

  ##
  # Finds the track with the largest valence value in the playlist and returns the valence for that track
  #
  # @return [Float]
  def max_valence
    track = tracks.max { |a, b| a.valence <=> b.valence }
    track.valence
  end

  ##
  # Finds the track with the smallest valence value in the playlist and returns the valence for that track
  #
  # @return [Float]
  def min_valence
    track = tracks.min { |a, b| a.valence <=> b.valence }
    track.valence
  end

  ##
  # Returns a hash of all the valence values in the playlist (rounded to one decimal place) with a count of the number of tracks with each valence value
  #
  # @return [Hash]
  def valence_distribution
    counts = Hash.new(0)
    tracks.each { |track| counts[track.valence.round(1)] += 1 }
    counts
  end

  ##
  # Adds songs to the playlist based on the user's listening history and the +target_valence+. The average valence of the songs added to the playlist should be roughly equal to +target_valence+. 
  #
  # @param [Float] target_valence The target average valence of the added songs
  # @param [Integer] num_songs The number of songs to add to the playlist
  #
  # @return [Integer] The number of songs added to the playlist
  def populate(target_valence, num_songs)
    candidate_tracks = self.user.recommended_tracks(target_valence)
    track_weights = {}
    weights_sum = 0

    # Assign each track a weight, add it to the track_weights hash and calculate the sum of all the weights
    candidate_tracks.each do |track|
      # Calculate the weight of each track by finding the percentage difference between the target_valenence and the track's valence
      diff = target_valence - track.valence
      percent_diff = diff.abs / ((target_valence + track.valence) / 2)
      percent_diff = 1 if percent_diff > 1

      # Tracks with a valence close to the target valence will have a weight near 1 and tracks with valence far away will have a weight near 0
      track_weights[track] = 1 - percent_diff
      weights_sum += track_weights[track]
    end

    # Select songs from the pool at semi-random and add them to the playlist
    num_songs.times do
      track = select_random_track(track_weights, weights_sum)
      # The following select method call is workaround for strange behaviour when calling track_weights[track] or track_weights.fetch(track) (both return nil even when track exists in track_weights)
      weights_sum -= track_weights.select{|t, w| t.id == track.id }.values[0]

      self.tracks << track
      track_weights.delete(track)
    end
  end

  ##
  # Clears playlist and repopulates it with songs based on the user's listening history and the +target_valence+. The average valence of the songs in the playlist should be roughly equal to +target_valence+. 
  #
  # @param [Float] target_valence The target average valence of the songs in playlist
  # @param [Integer] num_songs The number of songs to add to the playlist
  #
  # @return [Integer] The number of songs added to the playlist
  def repopulate(target_valence, num_songs)
    clear
    populate(target_valence, num_songs)
  end

  ##
  # Removes each track from the playlist, deleting it if it is no longer part of any playlists
  #
  # @return [Playlist]
  def clear
    tracks.each do |track|
      tracks.delete(track)
      track.destroy if track.playlists.size == 0
    end
  end

  private

  ##
  # Selects a track according to a weighted random number algorithm, which is more likely to return tracks with a higher weight
  #
  # Adapted from https://www.rubyguides.com/2016/05/weighted-random-numbers/
  #
  # @param [Hash] track_weights Tracks with associated weights
  # @param [Numeric] weights_sum The sum of all weights
  #
  # @return [Track]
  def select_random_track(track_weights, weights_sum)
    random_num = rand(weights_sum) # Get a random number >= 0 and < weights_sum
    track_weights.each do |track, weight|
      return track if random_num <= weight
      random_num -= weight
    end
  end
end