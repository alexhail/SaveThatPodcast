class HomeController < ApplicationController

  # GET '/'
  def index
    @episodes = Episode.all.sort(:_eid.asc)
  end

end
