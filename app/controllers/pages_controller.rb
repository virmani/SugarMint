class PagesController < ApplicationController

  before_filter :authenticate_user!, :only => [:home, :timeline]

  def home
    puts "ALL: #{current_user.all_checkins.length}"

    if user_signed_in? && current_user && current_user.events && current_user.events.length>0
      render 'timeline'
    else
      redirect_to :controller => 'events', :action => 'batch_new'
    end
  end

  def help
  end

  def about
  end

  def timeline
  end
end
