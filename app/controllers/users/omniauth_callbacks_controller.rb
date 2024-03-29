class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  # From the Devise OmniAuth guide: https://github.com/heartcombo/devise/wiki/OmniAuth:-Overview

  def spotify
    @user = User.from_omniauth(request.env["omniauth.auth"])

    if @user.persisted?
      sign_in_and_redirect @user, event: :authentication # this will throw if @user is not activated
      set_flash_message(:notice, :success, kind: "Spotify") if is_navigational_format?
    else
      session["devise.spotify_data"] = request.env["omniauth.auth"]
      redirect_to root_path
    end
  end

  def failure
    redirect_to root_path
  end
end