class VideosController < ApplicationController

  # *** FILTERS *** #
  before_action :get_video, only: [:edit, :update, :destroy]
  
  def new
    @video = Video.new
  end
  
  def create
    @video = Video.new(video_params)
    parsed_id = get_youtube_id(@video.youtube_url)
    # TO-DO NEED TO DRY THIS CODE BY MOVING TO VIDEO MODEL
    if parsed_id == -1
      @video.errors[:base] << "Youtube URL doesn't have proper video_id"
    else
      @video.youtube_id = parsed_id
    end
    @video.user = current_user
    
    p @video
    
    if @video.save
      redirect_to root_path
    else
      render 'new'
    end
  end
    
  def update
    @video.update_attributes(video_params)
    parsed_id = get_youtube_id(@video.youtube_url)
    # TO-DO NEED TO DRY THIS CODE BY MOVING TO VIDEO MODEL
    if parsed_id == -1
      @video.errors[:base] << "Youtube URL doesn't have proper video_id"
    else
      @video.youtube_id = parsed_id
    end
    
    if @video.save
      redirect_to root_path
    else
      render 'edit'
    end
  end
  
  def destroy
    @video.destroy!
    redirect_to root_path
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
      params.require(:video).permit(:title, :description, :youtube_id, :tag_list)
    end
    
    # TO-DO NEED TO DRY THIS CODE BY MOVING TO VIDEO MODEL
    def get_youtube_id(url)
      if url.blank?
        p url
        -1
      else
        regExp = /^.*(youtu.be\/|v\/|u\/\w\/|embed\/|watch\?v=|\&v=)([^#\&\?]*).*/
        match = url.match(regExp)
        if match&&match[2].length==11
          match[2]
        else
          -1
        end
      end 
    end

end
