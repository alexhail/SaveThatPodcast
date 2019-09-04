class DashboardController < ApplicationController
  before_action :authenticate_admin!

  include EpisodesHelper

  # GET '/dashboard'
  def index
    @font_options = @settings.font.map {|f| f.split("+").join(" ") }
    @background_image = @settings.background_image.empty? ? "Default Background" : @settings.background_image
    @admin_pin = Admin.first.pin
  end

  # GET '/dashboard/episodes'
  def episodes
    @episodes = Episode.all.order_by(_eid: :desc)
    @fields = Episode.visible_fields
  end

  # GET '/dashboard/hosts'
  def hosts
    @hosts = Host.all
  end

  # GET '/dashboard/guests'
  def guests
    @guests = Guest.all
  end
end
