class Devise::DisplayqrController < DeviseController
  prepend_before_action :authenticate_scope!, only: [:show, :update, :refresh]

  include Devise::Controllers::Helpers
	# layout "visitors"
  # GET /resource/displayqr
  def show
    if resource.nil? || resource.gauth_secret.nil?
      sign_in resource_class.new, resource
      redirect_to stored_location_for(scope) || :root
    else
      @tmpid = resource.assign_tmp
      render :show
    end
  end

  def update
    if resource.gauth_tmp != params[resource_name]['tmpid'] || !validate_token(resource,params[resource_name]['gauth_token'].to_i)
      set_flash_message(:error, :invalid_token)
      @tmpid = resource.assign_tmp
      render :show
      return
    end

    if resource.set_gauth_enabled(params[resource_name]['gauth_enabled'])
      if resource.gauth_enabled.eql?("0") || resource.gauth_enabled.eql?("f")
        resource.backup_code=nil
        resource.save!(validate:false)
        message="2FA is currently disabled"
      elsif resource.gauth_enabled.eql?("1")
        resource.backup_code=ROTP::TOTP.new(resource.get_qr).at(5.minute.ago)
        resource.save!(validate:false)
        message="2FA is currently enabled. Write down this number #{resource.backup_code} on the paper and store it safe. You need it if you lose your phone."
      end#if resource.gauth_enabled.eql?("0")
      sign_in scope, resource, bypass: true
      redirect_to "/toc",notice: message
    else
      render :show
    end
  end

  def refresh
    unless resource.nil?
      resource.send(:assign_auth_secret)
      resource.save
      set_flash_message :notice, :newtoken
      sign_in scope, resource, bypass: true
      redirect_to [resource_name, :displayqr]
    else
      redirect_to :root
    end
  end

  private
  def scope
    resource_name.to_sym
  end

  def authenticate_scope!
    send(:"authenticate_#{resource_name}!")
    self.resource = send("current_#{resource_name}")
  end

  # 7/2/15 - Unsure if this is used anymore - @xntrik
  def resource_params
    return params.require(resource_name.to_sym).permit(:gauth_enabled) if strong_parameters_enabled?
    params
  end

  def strong_parameters_enabled?
    defined?(ActionController::StrongParameters)
  end

 def validate_token(user,token)
     return false if user.gauth_tmp_datetime.nil?
    if user.gauth_tmp_datetime < user.class.ga_timeout.ago
      return false
    else
      if resource.gauth_enabled.eql?("1")
        valid_vals = [user.backup_code.to_i]
      else
        valid_vals = []
      end
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

