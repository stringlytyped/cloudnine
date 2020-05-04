class AdminMenuController< ApplicationController
    before_action :authenticate_user!
    
    def index_mine
      @mood_ratings = MoodRating
    end

  
    private
  
    def mood_params
      params.permit(:value)
    end
  end