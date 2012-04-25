class DiscussionsController < ApplicationController
  before_filter :require_login

  # GET /discussions
  # GET /discussions.json
  def index
    @discussions = Discussion.includes(:user)
                  .sort_by { |d| d.last_update_time }
                  .reverse
                  .paginate(page: params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @discussions }
    end
  end

  # GET /discussions/1
  # GET /discussions/1.json
  def show
    @discussion = Discussion.includes(:user, { :comments => :user }).find(params[:id])
    @comments = @discussion.comments.paginate page: params[:page]
    @comment = @discussion.comments.build

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @discussion }
    end
  end

  # GET /discussions/new
  # GET /discussions/new.json
  def new
    @discussion = Discussion.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @discussion }
    end
  end

  # GET /discussions/1/edit
  def edit
    @discussion = Discussion.includes(:user).find(params[:id])

    unless current_user == @discussion.user or current_user.admin?
      redirect_to discussions_path and return
    end
  end

  # POST /discussions
  # POST /discussions.json
  def create
    @discussion = current_user.discussions.build(params[:discussion])

    respond_to do |format|
      if @discussion.save
        format.html { redirect_to discussions_path, flash: { success: 'Discussion had been created.' } }
        format.json { render json: @discussion, status: :created, location: @discussion }
      else
        format.html { render action: "new" }
        format.json { render json: @discussion.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /discussions/1
  # PUT /discussions/1.json
  def update
    @discussion = Discussion.includes(:user).find(params[:id])

    unless current_user == @discussion.user or current_user.admin?
      redirect_to discussions_path and return
    end

    respond_to do |format|
      if @discussion.update_attributes(params[:discussion])
        format.html { redirect_to @discussion, flash: { success: 'Discussion had been updated.' } }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @discussion.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /discussions/1
  # DELETE /discussions/1.json
  def destroy
    @discussion = Discussion.includes(:user).find(params[:id])

    unless current_user == @discussion.user or current_user.admin?
      redirect_to discussions_path and return
    end

    @discussion.destroy

    respond_to do |format|
      format.html { redirect_to discussions_url, flash: { success: "Discussion had been destroyed." } }
      format.json { head :no_content }
    end
  end
end
