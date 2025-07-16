class JobMailer < ApplicationMailer

  def send_job_applicant_kyc_reminder(user,proof,subject)
    @user = user
    @proof = proof

    mail(from: ENV['MAIL_FROM_OFCCAP'],to: @user.email,bcc: ENV["BCC_MAIL"], subject: subject,date: Time.zone.now)
  end

  def user_blocked(user,banned,banned_reason)
    @user = user
    @banned = banned
    @banned_reason = banned_reason
    if @banned
      mail(from: ENV['MAIL_FROM_OFCCAP'],to: @user.email,bcc: ENV["BCC_MAIL"], subject: "[TheOfficeCapital™] Your profile is blocked", date: Time.zone.now)
    else
      mail(from: ENV['MAIL_FROM_OFCCAP'],to: @user.email,bcc: ENV["BCC_MAIL"], subject: "[TheOfficeCapital™] Your profile is unblocked", date: Time.zone.now)
    end#if @user.banned == true
  end#user_blocked(-,-,-)

  def user_aadhar_status_mail(user,aadhar_status,aadhar_rejected_reason)
    @user = user
    @aadhar_status = aadhar_status
    @aadhar_rejected_reason = aadhar_rejected_reason
    if aadhar_status == "accepted"
      mail(from: ENV['MAIL_FROM_OFCCAP'],to: @user.email,bcc: ENV["BCC_MAIL"], subject: "[TheOfficeCapital™] Your aadhar has been accepted [#{Time.zone.now.strftime('%H:%M:%S %Z')}].",date: Time.zone.now)
    elsif aadhar_status == "rejected"
      mail(from: ENV['MAIL_FROM_OFCCAP'],to: @user.email,bcc: ENV["BCC_MAIL"], subject: "[TheOfficeCapital™] Need your ATTENTION regarding your aadhar submission  [#{Time.zone.now.strftime('%H:%M:%S %Z')}].",date: Time.zone.now)
    end#if aadhar_status == "accepted"
  end#user_aadhar_status_mail(-,-,-)

  def user_resume_status_mail(user,resume_status,resume_rejected_reason)
    @user = user
    @resume_status = resume_status
    @resume_rejected_reason = resume_rejected_reason
    if resume_status == "accepted"
      mail(from: ENV['MAIL_FROM_OFCCAP'],to: @user.email,bcc: ENV["BCC_MAIL"], subject: "[TheOfficeCapital™] Your resume has been accepted [#{Time.zone.now.strftime('%H:%M:%S %Z')}].",date: Time.zone.now)
    elsif resume_status == "rejected"
      mail(from: ENV['MAIL_FROM_OFCCAP'],to: @user.email,bcc: ENV["BCC_MAIL"], subject: "[TheOfficeCapital™] Need your ATTENTION regarding your resume submission  [#{Time.zone.now.strftime('%H:%M:%S %Z')}].",date: Time.zone.now)
    end#if resume_status == "accepted"
  end#user_resume_status_mail(-,-,-)

  def user_exp_document_status_mail(user,exp_document_status,exp_document_rejected_reason)
    @user = user
    @exp_document_status = exp_document_status
    @exp_document_rejected_reason = exp_document_rejected_reason
    if exp_document_status == "accepted"
      mail(from: ENV['MAIL_FROM_OFCCAP'],to: @user.email,bcc: ENV["BCC_MAIL"], subject: "[TheOfficeCapital™] Your experience document has been accepted [#{Time.zone.now.strftime('%H:%M:%S %Z')}].",date: Time.zone.now)
    elsif exp_document_status == "rejected"
      mail(from: ENV['MAIL_FROM_OFCCAP'],to: @user.email,bcc: ENV["BCC_MAIL"], subject: "[TheOfficeCapital™] Need your ATTENTION regarding your experience document submission  [#{Time.zone.now.strftime('%H:%M:%S %Z')}].",date: Time.zone.now)
    end#if exp_document_status == "accepted"
  end#user_exp_document_status_mail(-,-,-)

  def profile_verified(user)
    @user = user
    mail(from: ENV['MAIL_FROM_OFCCAP'],to: @user.email,bcc: ENV["BCC_MAIL"], subject: "[TheOfficeCapital™] #{@user.full_name} - Your profile details are verified successfully.",date: Time.zone.now)
  end#profile_verified(-)

  def job_application_status_alert(job_application,email_body,subject)
    @job_application = job_application
    user = job_application.job_applicant
    @email_body = email_body
    mail(from: ENV['MAIL_FROM_OFCCAP'],to: user.email,bcc: ENV["BCC_MAIL"], subject: subject,date: Time.zone.now)
  end#job_application_status_alert(-,-,-)

  def send_interview_round_schedule_details(interview_round_status,email_body,email_subject)
    user = interview_round_status.job_applicant
    @email_body = email_body
    mail(from: ENV['MAIL_FROM_OFCCAP'],to: user.email,bcc: ENV["BCC_MAIL"], subject: email_subject,date: Time.zone.now)
  end

end#JobMailer