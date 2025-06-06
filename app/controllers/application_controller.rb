class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  def configure_permitted_parameters
    # For additional fields in app/views/devise/registrations/new.html.erb
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])

    # For additional in app/views/devise/registrations/edit.html.erb
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
  end

  # current_guest_for_session method
  # - Returns a cached result if already looked up
  # - Returns nil if no guest_id in session
  # - Looks up the Guest record by the ID stored in the session
  # - Makes the method available to views with helper_method
  def current_guest_for_session
    return @current_guest if defined?(@current_guest)
    return nil unless session[:guest_id].present?

    @current_guest = Guest.find_by(id: session[:guest_id])
  end
  
  helper_method :current_guest_for_session

end
