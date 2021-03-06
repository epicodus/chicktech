class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :configure_permitted_parameters, if: :devise_controller?

protected

  def after_sign_in_path_for(user)
    events_path
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:accept_invitation) do |u|
      u.permit(:first_name,
               :last_name,
               :phone,
               :password,
               :password_confirmation,
               :invitation_token,
               :city_id)
    end
  end

  helper_method :event_count

  def event_count
    Event.all.count
  end

  rescue_from CanCan::AccessDenied do |exception|
    flash[:alert] = "Access denied."
    redirect_to root_path
  end
end


