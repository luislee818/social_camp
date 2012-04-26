class DashboardController < ApplicationController
  before_filter :require_login

  def home
  	@discussions = Discussion.includes(:user)
                  .order('updated_at DESC')
                  .limit(10)

    @upcoming_events = Event.upcoming.limit(5)
  end
end
