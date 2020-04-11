class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :omniauthable, omniauth_providers: %i[spotify]
  rolify
  
  has_many :playlists, dependent: :destroy
  has_many :moods, dependent: :destroy

  def admin?
    has_role?(:admin)
  end

  def standard?
    has_role?(:standard)
  end 

  # Adapted from the Devise OmniAuth guide: https://github.com/heartcombo/devise/wiki/OmniAuth:-Overview
  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create
    # Can pass a block to first_or_create to set additional database fields from the data provided by Spotify (e.g. the user's email address) but we must comply with the Spotify Developer TOS which prohibits long-term storage of data
  end
end
