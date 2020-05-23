class AdminController< ApplicationController
    before_action :authenticate_user!
    
    def index
      @mood_ratings = MoodRating
    end
  end