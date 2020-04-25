module PlaylistsHelper
  def weather_icon(code, alt)
    url = "http://openweathermap.org/img/wn/#{code}@2x.png"
    image_tag(url, size: 50, alt: alt)
  end
end
