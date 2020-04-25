class WeatherUpdateJob < ApplicationJob
  queue_as :default

  ##
  # Schedules a new weather data update to be performed 15 minutes from now.
  #
  # @param [Location] location
  def self.schedule(location)
    set(wait: 15.minutes).perform_later(location)
  end

  ##
  # Updates the given location with the latest weather data.
  #
  # @param [Location] location
  def perform(location)
    location.update_weather_data!
  end
end
