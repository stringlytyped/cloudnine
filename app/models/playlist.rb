class Playlist < ApplicationRecord
  belongs_to :user
  has_and_belongs_to_many :tracks

  ##
  # Calculates the average valence of the tracks in the playlist
  #
  # @return [Float]
  def avg_valence()
    total_valence = self.tracks.reduce { |sum, track| sum + track.valence }
    total_valence / self.tracks.length
  end
end