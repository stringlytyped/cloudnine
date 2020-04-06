class HomeController < ApplicationController
  def index
    require 'net/http'
    require 'json'

    #@url = 'http://api.openweathermap.org/data/2.5/weather?q=London&appid=cb133295b04bc2c8c6ab41f01d95566c'    
    @url = 'http://api.openweathermap.org/data/2.5/weather?q=Guildford&appid=cb133295b04bc2c8c6ab41f01d95566c'  

    @uri = URI(@url)
    @respone = Net::HTTP.get(@uri)
    @output = JSON.parse(@respone)

=begin
    # Check for invalid parameters of location 
    if @output.empty? 
      @final_output = "Error"
    elsif !@output
      @final_output = "Error"
    else
      @final_output = @output['weather']
    end
=end
  end
end

