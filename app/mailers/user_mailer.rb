class UserMailer < ApplicationMailer

  def send_profile_mail(user,changes)
    @user = user
    @email = mask_email(@user)
    @changes = changes
    mail(from: ENV['MAIL_FROM_OFCCAP'],to: @user.email,bcc: ENV["BCC_MAIL"], subject: "[TheOfficeCapital™] Profile updated", date: Time.zone.now)
  end#send_profile_mail

  def user_blocked(user,banned,banned_reason)
    @user = user
    @email = mask_email(@user)
    @banned = banned
    @banned_reason = banned_reason
    if @banned
      mail(from: ENV['MAIL_FROM_OFCCAP'],to: @user.email,bcc: ENV["BCC_MAIL"], subject: "[TheOfficeCapital™] Your profile is blocked", date: Time.zone.now)
    else
      mail(from: ENV['MAIL_FROM_OFCCAP'],to: @user.email,bcc: ENV["BCC_MAIL"], subject: "[TheOfficeCapital™] Your profile is unblocked", date: Time.zone.now)
    end#if @user.banned == true
  end#user_blocked(-)

  def account_suspended(user,account_suspended,account_suspended_reason)
    @user = User.find(user.id)
    @account_suspended=account_suspended
    @account_suspended_reason=account_suspended_reason
    if account_suspended
      mail(from: ENV['MAIL_FROM_OFCCAP'],to: @user.email,bcc: ENV["BCC_MAIL"], subject: "[TheOfficeCapital™] Your account is temporarily suspended", date: Time.zone.now)
    else
      mail(from: ENV['MAIL_FROM_OFCCAP'],to: @user.email,bcc: ENV["BCC_MAIL"], subject: "[TheOfficeCapital™] Your account removed from suspension", date: Time.zone.now)
    end#if @user.banned == true
  end#account_suspended(-)

  def user_aadhar_status_mail(user,aadhar_status,aadhar_rejected_reason)
    @user = user
    @email = mask_email(@user)
    @aadhar_status = aadhar_status
    @aadhar_rejected_reason = aadhar_rejected_reason
    if aadhar_status == "accepted"
      mail(from: ENV['MAIL_FROM_OFCCAP'],to: @user.email,bcc: ENV["BCC_MAIL"], subject: "[TheOfficeCapital™] Your Aadhar has been accepted by our compliance team [Changed at #{Time.zone.now.strftime('%H:%M:%S %Z')}].",date: Time.zone.now)
    elsif aadhar_status == "rejected"
      mail(from: ENV['MAIL_FROM_OFCCAP'],to: @user.email,bcc: ENV["BCC_MAIL"], subject: "[TheOfficeCapital™] Need your ATTENTION regarding your Aadhar submission  [Changed at #{Time.zone.now.strftime('%H:%M:%S %Z')}].",date: Time.zone.now)
    end#if @user.u.aadhar_status == "accepted"
  end#user_aadhar_status_mail(-)

  ##Notifying user if his/her id proof is accepted or rejected
  def user_pan_card_status_mail(user,pan_card_status,pan_card_rejected_reason)
    @user = user
    @email = mask_email(@user)
    @pan_card_rejected_reason = pan_card_rejected_reason
    @pan_card_status = pan_card_status
    if pan_card_status == "accepted"
      mail(from: ENV['MAIL_FROM_OFCCAP'],to: @user.email,bcc: ENV["BCC_MAIL"], subject: "[TheOfficeCapital™] Your pan card has been accepted by our compliance team [Changed at #{Time.zone.now.strftime('%H:%M:%S %Z')}].",date: Time.zone.now)
    elsif pan_card_status == "rejected"
      mail(from: ENV['MAIL_FROM_OFCCAP'],to: @user.email,bcc: ENV["BCC_MAIL"], subject: "[TheOfficeCapital™] Need your ATTENTION regarding your pan card submission [Changed at #{Time.zone.now.strftime('%H:%M:%S %Z')}].",date: Time.zone.now)
    end#if @user.pan_card_status == "accepted"
  end#user_pan_card_status_mail(-)

  def user_company_id_card_status_mail(user,company_id_card_status,company_id_card_rejected_reason)
    @user = user
    @company_id_card_rejected_reason = company_id_card_rejected_reason
    @email = mask_email(@user)
    @company_id_card_status = company_id_card_status
    if company_id_card_status == "accepted"
      mail(from: ENV['MAIL_FROM_OFCCAP'],to: @user.email,bcc: ENV["BCC_MAIL"], subject: "[TheOfficeCapital™] Your company id card has been accepted by our compliance team [Changed at #{Time.zone.now.strftime('%H:%M:%S %Z')}].",date: Time.zone.now)
    elsif company_id_card_status == "rejected"
      mail(from: ENV['MAIL_FROM_OFCCAP'],to: @user.email,bcc: ENV["BCC_MAIL"], subject: "[TheOfficeCapital™] Need your ATTENTION regarding your company id card submission [Changed at #{Time.zone.now.strftime('%H:%M:%S %Z')}].",date: Time.zone.now)
    end#if @user.company_id_card_status == "accepted"
  end#user_company_id_card_status_mail(-)

  def profile_verified(user)
    @user = user
    @email = mask_email(@user)
    mail(from: ENV['MAIL_FROM_OFCCAP'],to: @user.email,bcc: ENV["BCC_MAIL"], subject: "[TheOfficeCapital™] #{@user.firstname} - Your profile KYC details are verified successfully.",date: Time.zone.now)
  end#profile_verified(-)

  def aadhar_upload(user,type,admin_id,admin_user)
    @user = user
    @email = mask_email(@user)
    @admin_mail = ENV['KYC_MAIL']
    @admin_id = admin_id
    subject = nil

    if admin_user == "admin"
      if type == "front"
        @filename = "admin_verified_aadhar_front-#{user.id}"
        
        if @user.admin_verified_aadhar_front.present?
          extension = @user.admin_verified_aadhar_front.content_type.split("/").last
          @filename = @filename + "." + extension 
          attachments.inline[@filename] = @user.admin_verified_aadhar_front.read
        end
      else
        @filename = "admin_verified_aadhar_back-#{user.id}"
        if @user.admin_verified_aadhar_back.present?
          extension = @user.admin_verified_aadhar_back.content_type.split("/").last
          @filename = @filename + "." + extension 
          attachments.inline[@filename] = @user.admin_verified_aadhar_back.read
        end
      end#if type == "front"
    else
      if type == "front"
        @filename = "aadhar_front-#{user.id}"
        if @user.aadhar_front.present?
          extension = @user.aadhar_front.content_type.split("/").last
          @filename = @filename + "." + extension 
          attachments.inline[@filename] = @user.aadhar_front.read
        end
      else
        @filename = "aadhar_back-#{user.id}"
        if @user.aadhar_back.present?
          extension = @user.aadhar_back.content_type.split("/").last
          @filename = @filename + "." + extension 
          attachments.inline[@filename] = @user.aadhar_back.read
        end
      end#if type == "front"
    end#if admin_user == "admin"
    if @user.firstname.present?
      subject = "[TheOfficeCapital™] #{@user.firstname} - KYC Team has submitted verified proof of user’s aadhar [Changed at #{Time.zone.now.strftime('%H:%M:%S %Z')}]"
    else
      subject = "[TheOfficeCapital™] User ##{@user.id} - KYC Team has submitted verified proof of user’s aadhar [Changed at #{Time.zone.now.strftime('%H:%M:%S %Z')}]"
    end#if @user.firstname.present?
    mail(from: ENV['MAIL_FROM_OFCCAP'],to: @admin_mail,bcc: ENV["BCC_MAIL"], subject: subject,date: Time.zone.now)
  end#aadhar_upload

  def pan_card_upload(user,type,admin_id,admin_user)
    @user = user
    @email = mask_email(@user)
    @admin_mail = ENV['KYC_MAIL']   
    @admin_id = admin_id
    subject = nil
    if admin_user == "admin"
      @filename = "admin_verified_pan_card-#{user.id}"
      if @user.admin_verified_pan_card.present?
        extension = @user.admin_verified_pan_card.content_type.split("/").last
        @filename = @filename + "." + extension 
        attachments.inline[@filename] = @user.admin_verified_pan_card.read
      end
    else
      @filename = "pan_card-#{user.id}"
      if @user.pan_card.present?
        extension = @user.pan_card.content_type.split("/").last
        @filename = @filename + "." + extension 
        attachments.inline[@filename] = @user.pan_card.read
      end
    end#if admin_user == "admin"

    if @user.firstname.present?
      subject = "[TheOfficeCapital™] #{@user.firstname} - KYC Team has submitted verified proof of user’s pan card [Changed at #{Time.zone.now.strftime('%H:%M:%S %Z')}]"
    else
      subject = "[TheOfficeCapital™] User ##{@user.id} - KYC Team has submitted verified proof of user’s pan card [Changed at #{Time.zone.now.strftime('%H:%M:%S %Z')}]"
    end#if @user.firstname.present?
    mail(from: ENV['MAIL_FROM_OFCCAP'],to: @admin_mail,bcc: ENV["BCC_MAIL"], subject: subject,date: Time.zone.now)
  end#pan_card_upload(user,type)

  def company_id_card_upload(user,admin_id)
    @user = user
    @email = mask_email(@user)
    @admin_mail = ENV['KYC_MAIL'] 
    @admin_id = admin_id  
    subject = nil

    @filename = "company_id_card-#{user.id}"
    if @user.company_id_card.present?
      extension = @user.company_id_card.content_type.split("/").last
      @filename = @filename + "." + extension 
      attachments.inline[@filename] = @user.company_id_card.read
    end
    
    if @user.firstname.present?
      subject = "[TheOfficeCapital™] #{@user.firstname} - KYC Team has submitted verified proof of user’s company id card  [Changed at #{Time.zone.now.strftime('%H:%M:%S %Z')}]"
    else
      subject = "[TheOfficeCapital™] User ##{@user.id} - KYC Team has submitted verified proof of user’s company id card [Changed at #{Time.zone.now.strftime('%H:%M:%S %Z')}]"
    end#if @user.firstname.present?
    mail(from: ENV['MAIL_FROM_OFCCAP'],to: @admin_mail,bcc: ENV["BCC_MAIL"], subject: subject,date: Time.zone.now)
  end#company_id_card_upload(user,type) 

  def send_kyc_reminder(user,proof,subject)
    @user = user
    @email = mask_email(@user)
    @proof = proof

    mail(from: ENV['MAIL_FROM_OFCCAP'],to: @user.email,bcc: ENV["BCC_MAIL"], subject: subject,date: Time.zone.now)
  end

  def bank_account_update_alert(bank_account,browser)

    @bank_account = BankAccount.find(bank_account.id)
    @user = @bank_account.user
    @email = mask_email(@user)
    
    if @bank_account.verify == true
      subject = "[TheOfficeCapital™] #{@user.firstname} - Your Bank Account details are accepted [Changed at #{Time.zone.now.strftime('%H:%M:%S %Z')}]"
    elsif @bank_account.reject_bank_account == true
      subject = "[TheOfficeCapital™] #{@user.firstname} - Need your ATTENTION regarding your Bank Account details  submission [Changed at #{Time.zone.now.strftime('%H:%M:%S %Z')}]"
    end#if @bank_account.verify == true

    @ip=@user.current_sign_in_ip 

    if !@ip.nil?
      @browser=browser
      location=ApplicationHelper.getLocationDetails(@ip)
      @country = location[:country]
      @city= location[:city]
    end      
    
    mail(from: ENV['MAIL_FROM_OFCCAP'],to: @user.email,bcc: ENV["BCC_MAIL"], subject: subject,date: Time.zone.now)
  end#bank_account_update_alert

  def send_cancel_withdraw_alert(withdraw)
    @user = withdraw.user
    @email = mask_email(@user)
    @withdraw = withdraw
    @mobile_number = mask_mobile_number(@withdraw.user)
    
    @bank_account = BankAccount.find(@withdraw.bank_account_id) rescue nil
    @cash_balance = @user.company.wallets.first.balance

    subject="[TheOfficeCapital™] #{@withdraw.reference_number} - Cash Withdrawal request has been cancelled for #{(@withdraw.withdraw_amount)} INR [#{Time.zone.now.strftime('%H:%M:%S %Z')}]"
    mail(from: ENV['MAIL_FROM_OFCCAP'],to: @user.email,bcc: ENV['BCC_MAIL'],subject: subject,date: Time.now)    
  end#send_cancel_withdraw_alert(-,-)

  def send_withdraw_confirmation(user,withdraw)
    @user=user
    @email = mask_email(@user)
    @withdraw=withdraw
    @bank_account=BankAccount.find(@withdraw.bank_account_id)
    @cash_balance=user.company.wallets.first.balance

    mail(from: ENV['MAIL_FROM_OFCCAP'],to: @user.email,bcc: ENV['BCC_MAIL'],subject: "[TheOfficeCapital™] #{@withdraw.reference_number} #{@withdraw.withdraw_amount} INR has been deposited to your bank account",date: Time.now)
  end#send_withdraw_confirmation(-,-)

  def track_changes(message,subject)  
    @subject = subject
    @message = message
    @admin_mail = ENV['ADMIN_TRACK_MAIL'] 
    mail(from: ENV['MAIL_FROM_OFCCAP'],to: @admin_mail,bcc: ENV["BCC_MAIL"],subject: "[TheOfficeCapital™] "+@subject,date: Time.zone.now)
  end#track_changes

  def change_email_request(id,user_mail,token,email)
    @user = User.find(id)
    @email = mask_email(@user)
    @user_mail = user_mail
    @token = token
    @send_email = email
    @url = ENV['OFFICE_CAPITAL_CONFIRMATION_URL']+"?confirmation_token=#{@token}"
    mail(from: ENV['MAIL_FROM_OFCCAP'],to: @send_email,bcc: ENV["BCC_MAIL"],subject: "[TheOfficeCapital™] #{@user.firstname} - Please confirm your email address",date: Time.zone.now)
  end

  def booking_cancellation_alert(booking,total_refund,refund_bonus,remaining_bonus,booking_cancellation_percentage,workspace_type)
    @booking = booking
    @total_refund = total_refund
    @refund_bonus = refund_bonus
    @remaining_bonus = remaining_bonus
    @user = @booking.user
    @workspace = @booking.workspace
    @total_paid = @booking.total_amount
    @cancelation_fee = @total_paid - @total_refund
    @fee_percentage = booking_cancellation_percentage
    @workspace_type = workspace_type

    subject = "[TheOfficeCapital™] #{@workspace_type.name} booking for #{@workspace.name} has been cancelled. [#{Time.zone.now.strftime('%H:%M:%S %Z')}]"

    mail(from: ENV['MAIL_FROM_OFCCAP'],to: @user.email,bcc: ENV["BCC_MAIL"],subject: subject,date: Time.now)
  end#booking_cancellation

  def booking_group_cancellation(booking_group,cancelled_booking_ids,partail_cancel,total_refund,refund_bonus,remaining_bonus,booking_cancellation_percentage,workspace_type)
    @booking_group = booking_group
    @cancelled_bookings = Booking.where("id in (?)",cancelled_booking_ids)
    @partail_cancel = partail_cancel
    @total_refund = total_refund
    @refund_bonus = refund_bonus
    @remaining_bonus = remaining_bonus
    @user = @booking_group.created_by
    @workspace = @cancelled_bookings.first.workspace
    @workspace_type = workspace_type
    @total_paid = @cancelled_bookings.sum(:total_amount)
    @cancelation_fee = @total_paid - @total_refund
    @fee_percentage = booking_cancellation_percentage
    @wallet_refund = (@total_refund - @refund_bonus).round(2)

    subject = "[TheOfficeCapital™] Booking for #{@workspace.name} has been cancelled by #{booking_group&.canceled_by&.email}. [#{Time.zone.now.strftime('%H:%M:%S %Z')}]"

    mail(from: ENV['MAIL_FROM_OFCCAP'],to: @user.email,bcc: ENV["BCC_MAIL"],subject: subject,date: Time.now)
  end#booking_group_cancellation(-,-)

  private

  def mask_email(obj)
    begin
      email = obj.email.split("@")
      length = email[0].length
      stars = "*" * (length-2)
      if stars.present?
        return email[0].first + stars + email[0].last + "@" + email[1]
      else
        return email[0].first + "*@" + email[1]
      end
    rescue => e
      p e.message
      puts e.backtrace.join("\n")
      return ""
    end#begin
  end#mask_email

  def mask_mobile_number(obj)
    begin
      return (obj.mobile_number.first(1) + "********" + obj.mobile_number.last(1))
    rescue => e
      p e.message
      puts e.backtrace.join("\n")
      return ""
    end#begin
  end#mask_mobile_number

end#UserMailer