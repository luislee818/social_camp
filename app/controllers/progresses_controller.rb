class ProgressesController < ApplicationController
  before_filter :require_login

  def all
  	@changelogs = Changelog.includes(:trackable, :user)
  							.paginate(page: params[:page], per_page: 20)
  end
end
