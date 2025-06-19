class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?
  
  protected
  
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:role])
    devise_parameter_sanitizer.permit(:account_update, keys: [:role])
  end
  
  def require_superadmin
    redirect_to root_path, alert: 'Access denied. Superadmin required.' unless current_user&.superadmin?
  end
  
  def require_user_or_superadmin
    redirect_to root_path, alert: 'Access denied.' unless current_user&.user? || current_user&.superadmin?
  end
end
