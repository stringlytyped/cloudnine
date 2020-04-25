class WeatherBroadcastJob < ApplicationJob
  queue_as :default

  ##
  # Broadcasts updated weather partial to clients subscribed to the broadcasting for the given location and schedules a new update to be performed at sometime in the future.
  #
  # @param [Location] location
  def perform(location)
    if WeatherChannel.location_has_subscribers?(location)
      WeatherChannel.broadcast_to(location, render_weather(location))
      WeatherUpdateJob.schedule(location)
    end
  end

  private

  ##
  # Renders weather partial with data from the given location.
  #
  # @param [Location] location
  def render_weather(location)
    PlaylistsController.render partial: "playlists/weather", locals: {location: location}
  end
end
