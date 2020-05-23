class AdminController< ApplicationController
  before_action :authenticate_user!
  before_action :restrict_to_admins!
  
  def index
    @mood_ratings = MoodRating
  end
end