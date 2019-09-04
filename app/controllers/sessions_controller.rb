class SessionsController < Devise::SessionsController

  # POST /admin
  def create
    if params[:pin] == Admin.first.pin.to_s
      sign_in(Admin.first)
      redirect_to dashboard_path, notice: "Admin Privileges Granted"
    else
      redirect_back fallback_location: root_path, alert: "Incorrect pin"
    end
  end

end