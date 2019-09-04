class StatisticsController < ApplicationController
  before_action :get_stat_object, only: [:update]

  include Modules::StatBuilder

  # PATCH '/stat_objects/init'
  def init
  end

  def create
    StatObject.create(stat_object_parameters)
  end

  def update
    unless @stat_obj.blank?
    end
  end

  def tick_media
    @stat_obj = StatObject.find_by(slug: 'traffic_to_social_media')

    unless accepted_media.empty?
      @stat_obj.data.each_with_index do |obj, i|
        if obj["name"] == accepted_media
           @stat_obj.data[i]["value"] += 1
        end
      end
    end

    @stat_obj.update
  end

  private
  def get_stat_object
    @stat_obj = StatObject.find(params[:id])
  end

  def stat_object_parameters
    params.require(:stat_object, {})
  end

  def accepted_media
    params.permit(:soundcloud, :twitter, :instagram, :itunes)
  end
end
