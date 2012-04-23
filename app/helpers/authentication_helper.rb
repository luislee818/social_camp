module AuthenticationHelper
  def require_login
    save_previously_requested_page
    redirect_to signin_path, notice: "Please sign in." unless signed_in?
  end

  def require_admin
    redirect_to root_path unless current_user.admin?
  end
end