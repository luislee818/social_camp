class CommentsController < ApplicationController
  before_filter :require_login

  def create
  	discussion = Discussion.find(params[:discussion_id])
  	comment = discussion.comments.build(params[:comment])
  	comment.user_id = current_user.id

  	if comment.save
  		redirect_to discussion, flash: { success: "Comment had been created." }
  	else
  		redirect_to discussion, flash: { error: "Comment was not created, please try again."}
  	end
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
    
    redirect_to @comment.discussion, flash: { success: "Comment had been updated." }
  end

  def destroy
    @comment = Comment.includes(:discussion).find(params[:id])
    
    unless @comment.user == current_user or current_user.admin?
      redirect_to discussions_path and return
    end
    
    @comment.destroy
    
    redirect_to @comment.discussion, flash: { success: "Comment had been destroyed." }
  end
end
