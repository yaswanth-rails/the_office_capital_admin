class CustomDeviseMailer < Devise::Mailer
  layout 'mailer'
  before_action :set_image

  def set_image
    attachments.inline["logo.png"] = File.read("#{Rails.root}/public/logo.png")
  end
  
	def headers_for(action, opts)
	  super.merge!({bcc: ENV["BCC_MAIL"]})
	end
	
	def confirmation_instructions(user, token, options={})
    # Use different e-mail templates for signup e-mail confirmation and for when a user changes e-mail address.
    @token=token
    @user=user
    # super
    mail(from: ENV['MAIL_FROM_OFCCAP'],to: @user.email,bcc: ENV["BCC_MAIL"],subject: "[TheOfficeCapital] Confirm your email id",date: Time.now)    
  end

end
