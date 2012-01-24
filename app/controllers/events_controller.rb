class EventsController < ApplicationController

  before_filter :authenticate_user!
  # GET /events
  # GET /events.json
  def index
    @events = current_user.events

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @events }
    end
  end

  # GET /events/1
  # GET /events/1.json
  def show
    @event = Event.find(params[:id])

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
    @event = Event.find(params[:id])
  end

  # POST /events
  # POST /events.json
  def create
    @event = Event.new(params[:event])

    respond_to do |format|
      if @event.save
        format.html { redirect_to @event, notice: 'Event was successfully created.' }
        format.json { render json: @event, status: :created, location: @event }
      else
        format.html { render action: "new" }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /events/batchnew
  def batch_new
    respond_to do |format|
      format.html
    end
  end

  # POST /events
  # POST /events.json
  def batch_create
    uploaded_io = params[:coPilotFile].tempfile

    #Skip a line
    line = uploaded_io.gets
    #event_type = EventType.find(1)

    ActiveRecord::Base.transaction do
      while(line = uploaded_io.gets)
        fields = line.split("\t")
        if fields[2] == '1'
        @timestamp = Time.at(convert_excel_timestamp(fields[0]))
        @bg = Float(fields[11])
        
        logger.debug @timestamp
        current_user.events.create(:eventtype_id => 1, :value => @bg, :is_manual => false, :event_time => @timestamp)
        end
      end
    end

    respond_to do |format|
      format.html { redirect_to :action => 'index' }
    #format.json { render json: @event, status: :created, location: @event }
    end
  end

  def convert_excel_timestamp(dateStr)
    @decimalNum = Float(dateStr);
    return (@decimalNum - 25569) * 86400;
  end

  # PUT /events/1
  # PUT /events/1.json
  def update
    @event = Event.find(params[:id])

    respond_to do |format|
      if @event.update_attributes(params[:event])
        format.html { redirect_to @event, notice: 'Event was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1
  # DELETE /events/1.json
  def destroy
    @event = Event.find(params[:id])
    @event.destroy

    respond_to do |format|
      format.html { redirect_to events_url }
      format.json { head :ok }
    end
  end
end
