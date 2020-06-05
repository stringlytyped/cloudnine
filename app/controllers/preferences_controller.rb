class PreferencesController < ApplicationController
  before_action :set_preferences

  def edit
  end

  def update
    location = Location.new_from_city(preference_params[:city])
    
    if location.save
      current_user.location = location
      current_user.save
      flash[:notice] = 'Your preferences were updated successfully.'
      redirect_to action: :edit
    else
      flash.now[:error] = 'Could not update your preferences.'
      render :edit
    end
  end

  def delete_user
    if params[:id] == current_user.id.to_s
      if current_user.destroy
        redirect_to root_path, notice: "Your Spotify account has been disconnected and all data deleted."
      else
        redirect_to preferences_path, flash: { error: "Could not delete your account." }
      end
    else
      redirect_to preferences_path, flash: { error: "Could not delete that account." }
    end
  end

  private

  def set_preferences
    location = current_user.location

    @city = location ? location.name : nil;
  end

  def preference_params
    params.permit(:city)
  end
end
