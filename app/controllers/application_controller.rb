module Current
  mattr_accessor :toc
end
class ApplicationController < ActionController::Base
  require 'devise'
  include ApplicationHelper
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception, prepend: true

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_paper_trail_whodunnit
  def paper_trail_enabled_for_controller
    current_toc
  end
  before_action :set_current_toc

  def set_current_toc
    if current_toc
      Current.toc = current_toc
    end
  end
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to main_app.root_path, alert: exception.message
  end
  protected

  def configure_permitted_parameters

    devise_parameter_sanitizer.permit(:sign_up)  { |u| u.permit(:email,:password, :last_sign_in_ip,:gauth_secret, :gauth_enabled, :gauth_tmp, :gauth_tmp_datetime) }
    devise_parameter_sanitizer.permit(:accept_invitation)  { |u| u.permit(:email,:password, :last_sign_in_ip,:gauth_secret, :gauth_enabled, :gauth_tmp, :gauth_tmp_datetime) }
    devise_parameter_sanitizer.permit(:account_update) { |u| u.permit(:email, :password,:current_password,:gauth_secret, :gauth_enabled, :gauth_tmp, :gauth_tmp_datetime) }
  end

  def after_sign_in_path_for(resource)
    '/toc'
  end 

end



