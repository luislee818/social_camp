class CommentsController < ApplicationController
  before_filter :require_login

  def create
  	discussion = Discussion.find(params[:discussion_id])
  	comment = discussion.comments.build(params[:comment])
  	comment.user_id = current_user.id

  	if comment.save
  		redirect_to discussion, flash: { success: "Your comment was added successfully." }
  	else
  		redirect_to discussion, flash: { error: "Your comment was not added, please try again."}
  	end
  end

  def edit
  end

  def update
  end

  def destroy
  end
end
