module AuthenticationHelper
  def require_login
    save_previously_requested_page
    redirect_to signin_path, notice: "Please sign in." unless signed_in?
  end

  def require_admin
    unless signed_in? && current_user.admin?
      redirect_to root_path 
    end
  end
end