class VideosController < ApplicationController

  # *** FILTERS *** #
  skip_before_action :authenticate_user!, only: [:index]
  before_action :get_video, only: [:edit, :update, :destroy, :show]

  def index
    @videos = Video.where('title LIKE ?', params[:search]).count(20)
  end

  def new
    @video = Video.new
  end
  
  def create
    @video = Video.new(video_params)
    @video.set_youtube_id
    @video.user = current_user
        
    if @video.save
      redirect_to video_path(@video)
    else
      render 'new'
    end
  end
    
  def update
    @video.update_attributes(video_params)
    @video.set_youtube_id    
    if @video.save
      redirect_to video_path(@video)
    else
      render 'edit'
    end
  end
  
  def destroy
    @video.destroy!
    redirect_to root_path
  end
  
  def get_random_video
    @video = Video.offset(rand(Video.count)).first
    if @video.blank?
      redirect_to new_video_path
    else
      respond_to do |format|
         format.json { render json: @video} # take the fields we need only 
      end    
    end
  end
  
  # *** HELPER METHODS *** #
  private
  
    def get_video
      if params[:video_id].blank? && params[:id].blank?
        raise ActionController::RoutingError.new('Not Found')
      elsif params[:id].blank?
        @video = Video.find(params[:video_id])
      else
        @video = Video.find(params[:id])
      end 
    end
    
    def video_params 
      params.require(:video).permit(:title, :description, :youtube_id, :youtube_url, :tag_list)
    end

end
