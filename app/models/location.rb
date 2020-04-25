require 'open_weather'

class Location < ApplicationRecord
  has_many :users

  after_update_commit :broadcast_update

  ##
  # Given a city/town name, returns a Location record to represent the given city/town and the weather data associated therewith, provided by the OpenWeather API.
  #
  # If a Location record already exists in the database, the existing record is returned and its attributes are updated with the values returned by the API. The new values aren't saved to the database.
  #
  # If no Location record exists in the database, a new one is initialized with values from the API. The record is not persisted to the database.
  #
  # @param [String] city_name A search string provided by the user to locate a city/town
  #
  # @return [Location]
  def self.new_from_city(city_name)
    resp = OpenWeather.fetch_current_data(q: city_name)
    location = Location.find_or_initialize_by(open_weather_id: resp["id"])
    location.set_weather_data(resp)
    location
  end

  ##
  # Given a city/town name, returns a Location record to represent the given city/town and the weather data associated therewith, provided by the OpenWeather API, and ensure it is saved to the database.
  #
  # If a Location record already exists in the database, the existing record is returned and its attributes are updated with the values returned by the API. The new values are saved to the database.
  #
  # If no Location record exists in the database, a new one is created with values from the API. The new record is persisted to the database.
  #
  # @param [String] city_name A search string provided by the user to locate a city/town
  #
  # @return [Location]
  def self.create_from_city(city_name)
    location = new_from_city(city_name)
    location.save
    location
  end

  ##
  # Updates the weather data for the Location by fetching the latest from the OpenWeather API (regardless of how long its been since the last update). The updated data is saved to the database.
  #
  # @return [Location]
  def update_weather_data!
    resp = OpenWeather.fetch_current_data(id: open_weather_id)
    set_weather_data(resp)
    save
    self
  end

  ##
  # Updates the weather data for the Location by fetching the latest from the OpenWeather API if it has been more than 15 minutes since the last update. The updated data is saved to the database.
  #
  # @return [Location]
  def update_weather_data
    if updated_at.nil? || updated_at < 15.minutes.ago
      update_weather_data!
    end
    self
  end

  ##
  # Sets the weather data for the Location using a Hash provided by the OpenWeather API.
  #
  # @return [Location]
  def set_weather_data(api_resp)
    self.attributes = {
      name: api_resp["name"],
      utc_offset: api_resp["timezone"],
      sunrise: DateTime.strptime(api_resp.dig("sys", "sunrise").to_s, "%s"),
      sunset: DateTime.strptime(api_resp.dig("sys", "sunset").to_s, "%s"),
      condition_id: api_resp.dig("weather", 0, "id"),
      condition_description: api_resp.dig("weather", 0, "description"),
      condition_icon: api_resp.dig("weather", 0, "icon"),
      temperature: api_resp.dig("main", "temp"),
      feels_like: api_resp.dig("main", "feels_like"),
      humidity: (api_resp.dig("main", "humidity") || 0) / 100.0,
      wind_speed: api_resp.dig("wind", "speed") || 0,
      cloud_cover: (api_resp.dig("clouds", "all") || 0) / 100.0,
      rainfall_1h: api_resp.dig("rain", "1h") || 0,
      rainfall_3h: api_resp.dig("rain", "3h") || 0,
      snowfall_1h: api_resp.dig("snow", "1h") || 0,
      snowfall_3h: api_resp.dig("snow", "3h") || 0
    }
    self
  end

  private

  ##
  # Broadcast the Location to subscribed clients (as a background job).
  #
  # @return [true]
  def broadcast_update
    WeatherBroadcastJob.perform_later(self)
    true
  end
    
end
