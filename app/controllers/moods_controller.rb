class MoodsController < ApplicationController
  # load_and_authorize_resource
  before_action :set_mood, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, except: [:index, :show]
  
  def index
    @moods = Mood.all
  end

  def show
  end

  def new
    @mood = Mood.new
  end

  def edit
  end

  def create
    @mood = Mood.new(mood_params)
    @mood.user = current_user
    if @mood.save
      redirect_to @mood, notice: 'Mood was successfully registered.'
    else
      render :new
    end
  end

  def update
    if @mood.update(mood_params)
      redirect_to @mood, notice: 'Mood was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @mood.destroy
    redirect_to moods_url, notice: 'Mood entry was successfully removed.'
  end

  private
  def set_mood
    @mood = Mood.find(params[:id])
  end

  def mood_params
    params.require(:mood).permit(:username, :rating, :when)
  end
end