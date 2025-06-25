class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_locale
  
  protected
  
  def set_locale
    session[:locale] = params[:locale] if params[:locale] && I18n.available_locales.include?(params[:locale].to_sym)
    I18n.locale = session[:locale] || extract_locale_from_accept_language_header || I18n.default_locale
  end
  
  def extract_locale_from_accept_language_header
    if request.env['HTTP_ACCEPT_LANGUAGE']
      request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first
    end
  end
  
  def default_url_options
    { locale: I18n.locale }
  end
  
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
