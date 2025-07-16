class ApplicationMailer < ActionMailer::Base
  layout 'mailer'
  before_action :set_image

  def set_image
        attachments.inline["logo.png"] = File.read("#{Rails.root}/public/logo.png")
  end
end
