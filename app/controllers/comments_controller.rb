class CommentsController < ApplicationController
  before_filter :require_login

  def create
  	discussion = Discussion.find(params[:discussion_id])
  	comment = discussion.comments.build(params[:comment])
  	comment.user_id = current_user.id

  	if comment.save
      log_add comment
      discussion.touch
      @comments = discussion.comments
      can_fit_in_one_page = @comments.length <= PER_PAGE

      if can_fit_in_one_page
        flash.now[:success] = "Comment had been created."
      else
        flash[:success] = "Comment had been created."
        @redirect_path = discussion_path(discussion)
      end

      @save_success = true
  	else
      flash.now[:error] = "Comment was not created, please try again."
  	end

    respond_to do |format|
      format.js
    end
  end

  def show
    @comment = Comment.includes(:discussion).find(params[:id])

    redirect_to @comment.discussion
  end

  def edit
    @comment = Comment.includes(:user, :discussion).find(params[:id])

    unless @comment.user == current_user or current_user.admin?
      redirect_to @comment.discussion and return
    end
  end

  def update
    @comment = Comment.includes(:discussion).find(params[:id])

    unless @comment.user == current_user or current_user.admin?
      redirect_to discussions_path and return
    end

    @comment.update_attributes(params[:comment])

    log_update @comment
    @comment.discussion.touch

    redirect_to @comment.discussion, flash: { success: "Comment had been updated." }
  end

  def destroy
    @comment = Comment.includes(:discussion).find(params[:id])

    unless @comment.user == current_user or current_user.admin?
      redirect_to discussions_path and return
    end

    @comment.destroy
    log_destroy @comment
    @comment.discussion.touch

    redirect_to @comment.discussion, flash: { success: "Comment had been destroyed." }
  end
end
