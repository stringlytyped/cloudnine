class HomeController < ApplicationController

  def index
    require 'net/http'
    require 'json'

    location = params[:location]
    url = ''
    url.concat('http://api.openweathermap.org/data/2.5/weather?q=' + location.to_s + '&appid=cb133295b04bc2c8c6ab41f01d95566c&units=metric')
    #@url = 'http://api.openweathermap.org/data/2.5/weather?q=London&appid=cb133295b04bc2c8c6ab41f01d95566c&units=metric'    


    @uri = URI(url)
    @respone = Net::HTTP.get(@uri)
    @output = JSON.parse(@respone)
    @location
=begin
    # Check for invalid parameters of location 
    if @output.empty? 
      @final_output = "Error"
    elsif !@output
      @final_output = "Error"
    else
      @final_output = @output['weather', 'main']
    end
=end
  end
end

