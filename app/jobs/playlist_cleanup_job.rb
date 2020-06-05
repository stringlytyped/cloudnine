class PlaylistCleanupJob < ApplicationJob
  queue_as :default

  ##
  # Cleans up all playlists belonging to inactive users and schedules another cleanup to take place in 24 hours.
  def perform
    puts "Performing cleanup of playlist belonging to inactive users..."
    Playlist.destroy_stale
    puts "Cleanup complete."
    self.class.set(wait: 24.hours).perform_later
  end
end
