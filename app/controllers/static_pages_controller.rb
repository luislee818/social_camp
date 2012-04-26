class StaticPagesController < ApplicationController
  def home
  	redirect_to dashboard_path if signed_in?
  end

  def help
  end

  def about
  end

  def contact
  end
end
