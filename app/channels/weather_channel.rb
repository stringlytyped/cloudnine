class WeatherChannel < ApplicationCable::Channel
  # Array for keeping track of locations that have subscribers which need to be notified of updates
  @@locations_with_subscribers = []

  ##
  # Checks whether the given location has any active subscibers that should be notified of weather data changes.
  #
  # @param [Location] location
  #
  # @return [true] if the location has subscribers
  # @return [false] if the location does not have subscribers
  def self.location_has_subscribers?(location)
    @@locations_with_subscribers.include? location.id
  end

  ##
  # Callback called when a client subscribes to the channel. Creates a new broadcasting for the location (identified by the location id provided by the client) and schedules weather data to be updated sometime in the future.
  def subscribed
    location_id = params[:location_id].to_i
    location = Location.find(location_id)
    stream_for location
    
    @@locations_with_subscribers << location_id

    WeatherUpdateJob.schedule(location)
  end

  ##
  # Callback called when a client disconnects from the channel.
  def unsubscribed
    location_id = params[:location_id].to_i
    @@locations_with_subscribers.delete(location_id)
  end
end