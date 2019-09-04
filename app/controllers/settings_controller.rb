class SettingsController < ApplicationController

  # PATCH /setting/:id
  def update

    unless params[:pin].blank?
      @admin = Admin.first
      @admin.pin = params[:pin].gsub(/\D/, '')
      @admin.update
    end

    @settings.color = params[:color] unless params[:color].blank?
    @settings.font.unshift(params[:new_font]) unless params[:new_font].blank?

    unless params[:font].blank?
      font = @settings.font.delete(params[:font])

      unless font.nil?
        @settings.font.insert(0, font)
      end
    end

    unless params[:background_image].blank?
      if params[:background_image].start_with?('https://i.imgur.com/', 'i.imgur.com/', '/assets', 'https://i65.tinypic.com', 'http://i66.tinypic.com')
        image_url = params[:background_image]

        unless image_url[/\Ahttp:\/\//] || image_url[/\Ahttps:\/\//] || image_url.start_with?('/assets')
          image_url = "http://#{image_url}"
        end

        @settings.background_image = image_url

        if @settings.update
          redirect_to dashboard_path, notice: "General settings successfully updated."
        else
          redirect_to dashboard_path, alert: "There was an error updating general settings."
        end
      else
        if @settings.update
          redirect_to dashboard_path, alert: "Settings saved but background image not valid, contained an incorrect host prefix"
        end
      end
    else
      if @settings.update
        redirect_to dashboard_path, notice: "General settings successfully updated."
      else
        redirect_to dashboard_path, alert: "There was an error updating general settings."
      end
    end
  end
end
