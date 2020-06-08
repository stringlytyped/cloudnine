class StartPageController < ApplicationController
  before_action :authenticate_user!
  layout "page"

  def start
    if current_user.privacy_consent_needed?
      render "privacy"
    elsif !current_user.location
      render "location"
    elsif current_user.time_since_last_mood_rating > 12.hours
      render "mood"
    else
      redirect_to playlist_path
    end
  end

  def save
    if start_params[:accept_privacy]
      current_user.privacy_consent_at = Time.now

      unless current_user.save
        flash[:error] = "Privacy consent could not be saved."
        render :edit and return
      end
    elsif start_params[:city]
      location = Location.new_from_city(start_params[:city])
      current_user.location = location

      unless location.save && current_user.save
        flash[:error] = "Could not save that location. Make sure the city/town name is entered correctly."
        @city = start_params[:city]
        render :edit and return
      end
    elsif start_params[:value]
      mood_rating = MoodRating.new(start_params)
      mood_rating.user = current_user

      if mood_rating.save
        current_user.playlist.repopulate(current_user.target_valence, 30) 
      else
        flash[:error] = "Mood could not be recorded."
        render :edit and return
      end
    end
    redirect_to action: :start
  end

  private

  def start_params
    params.permit(:city, :accept_privacy, :value)
  end
end
