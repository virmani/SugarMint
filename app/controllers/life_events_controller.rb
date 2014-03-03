class LifeEventsController < ApplicationController

  before_filter :authenticate_user!, :only => [:home, :timeline]

  # GET /life_events
  # GET /life_events.json
  def index
    if user_signed_in?
      @life_events = current_user.all_checkins.map { |checkin| LifeEvent.from_foursquare_checkin(checkin).to_hash}.sort {
        |x,y| x[:occured_at] <=> y[:occured_at]
      }

      respond_to do |format|
        format.html # index.html.erb
        format.json { render :json => @life_events }
      end
    end
  end

  # GET /life_events/1
  # GET /life_events/1.json
  def show
    @life_event = LifeEvent.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @life_event }
    end
  end
end
