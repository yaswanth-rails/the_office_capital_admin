class Devise::CheckgaController < Devise::SessionsController
  prepend_before_action :devise_resource, only: [:show]
  prepend_before_action :require_no_authentication, only: [ :show, :update ]
  before_action :authenticate_with_token!, only: [:update], if: :check_auth_for_mobile
  include Devise::Controllers::Helpers

  def check_auth_for_mobile
    !request.headers['Device'].nil? and !request.headers['Authorization'].nil?
  end  

  def show
    @tmpid = params[:id]
    if @tmpid.nil?
      redirect_to :root
    else
      render :show
    end
  end

  def update
    resource = resource_class.find_by_gauth_tmp(params[resource_name]['tmpid'])

    if not resource.nil?
      if validate_token(resource,params[resource_name]['gauth_token'].to_i)
        # set_flash_message(:notice, :signed_in) if is_navigational_format?
        flash[:notice]="Signed in successfully from token."
        if !request.headers['Authorization'].nil? and !request.headers['Device'].nil? and request.headers['Device'].eql?"Mobile_app"          
          render(
            json: Api::V1::UserSerializer.gauth_success_message(flash[:notice]).to_json,
            status: 200
          )
          return
        else
          sign_in(resource_name,resource)
          warden.manager._run_callbacks(:after_set_user, resource, warden, {event: :authentication})
          respond_with resource, location: after_sign_in_path_for(resource)

          if not resource.class.ga_remembertime.nil? 
            cookies.signed[:gauth] = {
              value: resource.email << "," << Time.now.to_i.to_s,
              secure: !(Rails.env.test? || Rails.env.development?),
              expires: (resource.class.ga_remembertime + 1.days).from_now
            }
          end        
        end#if !request.headers['Authorization'].nil?            
      else
        # set_flash_message(:error, :error)
        flash[:error]="Sign in failed"
        if !request.headers['Authorization'].nil? and !request.headers['Device'].nil? and request.headers['Device'].eql?"Mobile_app"          
            render(
              json: Api::V1::UserSerializer.gauth_failure_message(flash[:error]).to_json,
              status: 422
            )
          return
        end#if !request.headers['Authorization'].nil?
        redirect_to :root
      end
    else
      set_flash_message(:error, :error)
        if !request.headers['Authorization'].nil? and !request.headers['Device'].nil? and request.headers['Device'].eql?"Mobile_app"          
            render(
              json: Api::V1::UserSerializer.gauth_failure_message("Sign in failed").to_json,
              status: 422
            )
          return
        end#if !request.headers['Authorization'].nil?
      redirect_to :root
    end
  end

  private

  def devise_resource
    self.resource = resource_class.new
  end
  
  def validate_token(user,token)
    return false if user.gauth_tmp_datetime.nil?
    if user.gauth_tmp_datetime < user.class.ga_timeout.ago
      return false
    else
      valid_vals = [user.backup_code.to_i]
      valid_vals << ROTP::TOTP.new(user.get_qr).at(Time.now)
      (1..user.class.ga_timedrift).each do |cc|
        valid_vals << ROTP::TOTP.new(user.get_qr).at(Time.now.ago(30*cc))
        valid_vals << ROTP::TOTP.new(user.get_qr).at(Time.now.in(30*cc))
      end
      if valid_vals.include?(token.to_i)
        return true
      else
        return false
      end
    end
  end#validate_token
end