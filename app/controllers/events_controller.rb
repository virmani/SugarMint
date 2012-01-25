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
    uploaded_io.set_encoding('iso-8859-1:utf-8')
  
    #Skip a line
    line = uploaded_io.gets
    #event_type = EventType.find(1)

    ActiveRecord::Base.transaction do
      while(line = uploaded_io.gets)
        fields = line.split("\t")
        timestamp = Time.at(convert_excel_timestamp(fields[0]))
        value = -1
        event_type = -1
        should_insert = true;
        comment = fields[36]

        if fields[2] == '1'
          #BG reading
          value = Float(fields[11])
          event_type = 1
          current_user.events.create(:eventtype_id => event_type, :value => value, :is_manual => false, :event_time => timestamp, :comment => comment)
          
        elsif fields[2] == '2' && (fields[10] == '0' || fields[10] == '1')
          #Basal Rate change
          value = Float(fields[20])
          event_type = 2
          current_user.events.create(:eventtype_id => event_type, :value => value, :is_manual => false, :event_time => timestamp, :comment => comment)
          
          if fields[26].index("Pod activated") != -1
            #New Pod activated
            value = 0.0
            event_type = 2
            current_user.events.create(:eventtype_id => event_type, :value => value, :is_manual => false, :event_time => timestamp, :comment => "New Pod Activated")
          end
          
        elsif fields[2] == '3' && (fields[10] == '0' || fields[10] == '1')
          #Bolus Intake
          value = Float(fields[20])
          event_type = 3
          comment = (fields[27] + "<br/>" + fields[36])
          current_user.events.create(:eventtype_id => event_type, :value => value, :is_manual => false, :event_time => timestamp, :comment => comment)
          
        elsif fields[2] == '5'
          #food intake
          value = Float(fields[21])
          event_type = 4
          current_user.events.create(:eventtype_id => event_type, :value => value, :is_manual => false, :event_time => timestamp, :comment => comment)
        end
      end
    end

    respond_to do |format|
      format.html { redirect_to :action => 'index' }
    #format.json { render json: @event, status: :created, location: @event }
    end
  end

  def convert_excel_timestamp(dateStr)
    return (Float(dateStr) - 25569) * 86400;
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
