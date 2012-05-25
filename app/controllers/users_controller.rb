class UsersController < ApplicationController
  before_filter :require_login, only: [:index, :show, :edit, :update, :destroy]
  before_filter :require_current_user_or_admin, only: [:edit, :update]
  before_filter :require_admin, only: [:destroy]
  
  def index
    @users = User.paginate(page: params[:page])
  end
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:success] = "Welcome on board, #{@user.name}."
      sign_in @user
      redirect_to @user
    else
      render 'new'
    end
  end
  
  def show
    @user = User.find(params[:id])
    @changelogs = @user.changelogs.paginate(page: params[:page], per_page: 20)
  end
  
  def edit
    @user = User.find(params[:id])
  end
  
  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      flash[:success] = "Your profile had been updated."
      redirect_to @user
    else
      render 'edit'
    end
  end
  
  def destroy
    user_to_delete = User.includes(:events, :discussions, :comments).find(params[:id])

    unless current_user == user_to_delete
      user_to_delete.destroy
      flash[:success] = "User #{user_to_delete.name} had been destroyed."
    end
    
    redirect_to users_path
  end

  private
  
    def attempt_to_access_own_profile?
      user = User.find(params[:id])
      current_user?(user)
    end
    
    def require_current_user_or_admin
      unless attempt_to_access_own_profile? || current_user.admin?
        redirect_to root_path
      end
    end

end
