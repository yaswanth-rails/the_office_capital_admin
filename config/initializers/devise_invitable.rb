module DeviseInvitable
  module Mailer
    def invitation_instructions(record, token, opts = {})
      @token = token
      devise_mail record, :invitation_instructions, opts.merge(bcc: ENV["BCC_MAIL"])
    end
  end
end

