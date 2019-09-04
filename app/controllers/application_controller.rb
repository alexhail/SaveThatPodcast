class ApplicationController < ActionController::Base
  before_action :apply_settings

  GENERAL_SETTINGS = Setting.find_by(slug: "general")

  def apply_settings
    @settings = GENERAL_SETTINGS
  end

  # Devise authenticate and notice
  protected
  def authenticate_admin!
    if admin_signed_in?
      super
    else
      redirect_to root_path, :alert => 'You don\'t have permission to view that page'
      ## if you want render 404 page
      ## render :file => File.join(Rails.root, 'public/404'), :formats => [:html], :status => 404, :layout => false
    end
  end
end
