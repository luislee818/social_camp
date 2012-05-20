class FeedsController < ApplicationController
  def discussions
    @discussions = Discussion.includes(:user)
                  .order('updated_at DESC')
                  .limit(20)
  end

  def events
    @event_updates = Changelog.includes(:trackable, :user)
                  .where('trackable_type = ?', TrackableType::EVENT)
                  .order('updated_at DESC')
  							  .limit(20)
  end

  def progresses
    @changelogs = Changelog.includes(:trackable, :user)
                  .order('updated_at DESC')
                  .limit(20)
  end
end
