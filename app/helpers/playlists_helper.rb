module PlaylistsHelper
  def weather_icon(code, alt)
    suffix = 
      case code
        when "01d"
          "sunny"
        when "01n"
          "clear"
        when "02d"
          "mostly-sunny"
        when "02n"
          "mostly-clear"
        when "03d", "03n"
          "partly-cloudy"
        when "04d", "04n"
          "mostly-cloudy"
        when "09d", "09n", "10d", "10n"
          "rain"
        when "11d", "11n"
          "thunder"
        when "13d", "13n"
          "snow"
        when "50d", "50n"
          "fog"
      end

    url = "/assets/weather_#{suffix}.svg"
    image_tag(url, alt: alt)
  end
end
