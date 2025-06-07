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
  # - session[:guest_id] is stored in the browser's encrypted session cookie
  # - This gets set when a guest joins via QR code and submits their nickname
  # - If no guest_id exists, this person hasn't joined as a guest → return nil
  # - Looks up the guest record within this specific karaoke session
  # - The guest must belong to @session (not just any session)
  # - Makes the method available to views with helper_method
  #
  def current_guest_for_session
    return @current_guest if defined?(@current_guest)
    return nil unless session[:guest_id].present?

    @current_guest = @session.guests.find_by(id: session[:guest_id])
  end

  helper_method :current_guest_for_session


  # verify_host_or_guest method
  # - Makes the method available to views with helper_method

  def verify_host_or_guest
    is_host = @session.user == current_user
    is_guest = current_guest_for_session
    redirect_to root_path unless is_host || is_guest
  end

  helper_method :verify_host_or_guest

end
