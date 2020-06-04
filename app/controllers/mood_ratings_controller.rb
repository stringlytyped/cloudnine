class MoodRatingsController < ApplicationController
  before_action :authenticate_user!
  
  def index_mine
    @mood_ratings = current_user.mood_ratings
    render layout: false
  end

  def create
    @mood_rating = MoodRating.new(mood_params)
    @mood_rating.user = current_user
    if @mood_rating.save
      redirect_to playlist_path, notice: 'Mood was successfully recorded.'
    else
      redirect_to playlist_path, error: 'Mood could not be recorded.'
    end
  end

  private

  def mood_params
    params.permit(:value)
  end
end