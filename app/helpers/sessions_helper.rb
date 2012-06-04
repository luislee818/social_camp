module SessionsHelper
  COOKIE_EXPIRATION = 14.days.from_now
  
  def sign_in(user)
    cookies[:user_id] = { value: user.id, expires: COOKIE_EXPIRATION }
    current_user = user
  end
  
  def sign_out
    current_user = nil
    cookies.delete :user_id
  end
  
  def current_user
    @current_user ||= user_from_recognized_cookie
  end
  
  def signed_in?
    true unless current_user.nil?
  end
  
  def current_user?(user)
    current_user == user
  end
  
  def save_previously_requested_page
    session[:requested_page] = request.fullpath
  end
  
  def redirect_to_previously_requested_page_or(default)
    page_to_redirect = session[:requested_page] || default
    redirect_to page_to_redirect
    clear_requested_page
  end
  
  private

    def user_from_recognized_cookie
      User.find(cookies[:user_id]) unless cookies[:user_id].blank?
    end
    
    def clear_requested_page
      session.delete :requested_page
    end
end
