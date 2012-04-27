class SessionsController < ApplicationController
  def new
    
  end
  
  def create
    user = User.find_by_email(params[:email])
    if user && user.authenticate(params[:password])
      sign_in user
      flash[:info] = "Welcome back, #{user.name}."
      redirect_to_previously_requested_page_or user
    else
      flash.now[:error] = "Invalid email/password combination"
      render 'new'
    end
  end
  
  def destroy
    sign_out
    flash[:info] = "You've successfully signed out"
    redirect_to root_path
  end
  
end
