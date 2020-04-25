require 'json'

class OpenWeather
  @@endpoint = "https://api.openweathermap.org/data/2.5/weather"

  @@options = {
    APPID: Rails.application.credentials.open_weather[:key],
    units: "metric"
  }

  ##
  # Fetches the current weather data for a location from the OpenWeather API.
  #
  # Can look up by city name by passing in the :q option or by OpenWeather city ID by passing in the :id option. Refer to https://openweathermap.org/current to see other available +options+.
  #
  # Defaults to returning metric units.
  #
  # @param [Hash] options Data to send with the request as query parameters
  #
  # @return [Hash] if a 200 response is received
  # @return [nil] if the request fails
  def self.fetch_current_data(options)
    options = @@options.merge(options)
    uri = URI.parse(@@endpoint)
    uri.query = options.to_query

    net = Net::HTTP.new(uri.host, uri.port)
    net.use_ssl = true
    net.read_timeout = 30
    resp = net.get(uri.request_uri)

    if resp.kind_of? Net::HTTPSuccess
      JSON.parse(resp.body)
    else
      nil
    end
  end
end