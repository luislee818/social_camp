class EventsController < ApplicationController
  before_filter :require_login

  # GET /events
  # GET /events.json
  def index
    @upcoming_events = Event.upcoming
    @past_events = Event.past

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @events }
    end
  end

  # GET /events/1
  # GET /events/1.json
  def show
    @event = Event.includes(:user, :changelogs).find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @event }
    end
  end

  # GET /events/new
  # GET /events/new.json
  def new
    @event = Event.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @event }
    end
  end

  # GET /events/1/edit
  def edit
    @event = Event.includes(:user).find(params[:id])

    unless current_user == @event.user or current_user.admin?
      redirect_to events_path and return
    end
  end

  # POST /events
  # POST /events.json
  def create
    @event = current_user.events.build(params[:event])

    respond_to do |format|
      if @event.save
        log_change @event, ActionType::ADD

        format.html { redirect_to events_path, flash: { success: 'Event had been created.' } }
        format.json { render json: @event, status: :created, location: @event }
      else
        format.html { render action: "new" }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /events/1
  # PUT /events/1.json
  def update
    @event = Event.includes(:user).find(params[:id])

    unless current_user == @event.user or current_user.admin?
      redirect_to events_path and return
    end

    respond_to do |format|
      if @event.update_attributes(params[:event])
        log_change @event, ActionType::UPDATE

        format.html { redirect_to @event, flash: { success: 'Event had been updated.' } }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1
  # DELETE /events/1.json
  def destroy
    @event = Event.includes(:user).find(params[:id])

    unless current_user == @event.user or current_user.admin?
      redirect_to events_path and return
    end

    @event.destroy

    log_change @event, ActionType::DESTROY

    respond_to do |format|
      format.html { redirect_to events_url, flash: { success: "Event #{@event.name} had been destroyed." } }
      format.json { head :no_content }
    end
  end

end
