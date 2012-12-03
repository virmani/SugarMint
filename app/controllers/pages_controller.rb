class PagesController < ApplicationController

  before_filter :authenticate_user!, :only => [:home, :timeline]

  def home
    if user_signed_in? && current_user && current_user.events && current_user.events.length>0
      redirect_to :controller => 'pages', :action => 'timeline' and return
    else
      redirect_to :controller => 'events', :action => 'batch_new' and return
    end
  end

  def help
  end

  def about
  end

  def timeline
  end
end
