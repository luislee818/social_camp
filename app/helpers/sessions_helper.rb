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
  
  def current_user=(user)
    @current_user = user
  end
  
  def current_user
    @current_user ||= user_from_recognized_cookie
  end
  
  def signed_in?
    true unless current_user.nil?
  end
  
  private
  
    def user_from_recognized_cookie
      User.find(cookies[:user_id]) if cookies[:user_id]
    end
end
