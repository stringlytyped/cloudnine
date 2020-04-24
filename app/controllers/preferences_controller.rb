class PreferencesController < ApplicationController
  before_action :set_preferences

  def edit
  end

  def update
    location = Location.new_from_city(preference_params[:city])
    
    if location.save
      current_user.location = location
      flash[:notice] = 'Your preferences were updated successfully.'
      redirect_to action: :edit
    else
      flash.now[:alert] = 'Could not update your preferences.'
      render :edit
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
