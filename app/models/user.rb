class User < ApplicationRecord 
	include Current
	attr_accessor :current_toc  
	has_paper_trail on: [:update, :destroy], ignore: [:track_changes,:sign_in_count, :current_sign_in_at,:last_sign_in_at,:current_sign_in_ip,:last_sign_in_ip,:updated_at], if: Proc.new { Current.toc }
	attr_accessor :gauth_token
	# after_update :send_alert_email
	attr_accessor :executed
	# after_update :send_mails
  after_update :user_kyc_check_update  
	after_update :send_info
	after_update :change_email, unless: :executed  
	after_commit :upload_proofs, unless: :executed
	after_commit :track_changes_in_table, unless: :executed
	has_many :login_histories

	has_many :invitations, class_name: self.to_s, as: :invited_by
	belongs_to :invited_by, optional: true, polymorphic: true
  belongs_to :group, optional: true
  has_one :company, through: :group
  has_many :bookings
  has_many :reviews
  has_many :wallet_histories
  has_many :deposits
  has_many :bank_accounts
  has_many :withdraws
	has_many :user_coupon_uses
  has_many :used_coupons, through: :user_coupon_uses, source: :coupon
  has_many :invoices, dependent: :destroy

	mount_uploader :profile_pic, PicUploader
  mount_base64_uploader :aadhar_front, KycUploader
  mount_base64_uploader :aadhar_back, KycUploader
  mount_base64_uploader :admin_verified_aadhar_front, KycUploader
  mount_base64_uploader :admin_verified_aadhar_back, KycUploader
  mount_base64_uploader :company_id_card, KycUploader
  mount_base64_uploader :pan_card, KycUploader
  mount_base64_uploader :admin_verified_pan_card, KycUploader

	validate :email_in_use, on: [:update]

  validates :aadhar_number,
  uniqueness: true,
  allow_nil: true,
  allow_blank: true

  validates :pan_number,
  uniqueness: true,
  allow_nil: true,
  allow_blank: true
	validates :mobile_number, uniqueness: { scope: :country_code }, allow_blank: true, allow_nil: true#, on: :create
	validates :mobile_number2, uniqueness: { scope: :country_code }, allow_blank: true, allow_nil: true, unless: lambda{ |user| user.mobile_number2.blank? or user.mobile_number2.eql?"0"} #, on: :create
	validates :mobile_number3, uniqueness: { scope: :country_code }, allow_blank: true, allow_nil: true, unless: lambda{ |user| user.mobile_number3.blank? or user.mobile_number3.eql?"0" } #, on: :create
	validates :mobile_number4, uniqueness: { scope: :country_code }, allow_blank: true, allow_nil: true, unless: lambda{ |user| user.mobile_number4.blank? or user.mobile_number4.eql?"0" } #, on: :create
	validates :mobile_number5, uniqueness: { scope: :country_code }, allow_blank: true, allow_nil: true, unless: lambda{ |user| user.mobile_number5.blank? or user.mobile_number5.eql?"0" } #, on: :create  
	validates :referral_code, uniqueness: true
	validates_format_of :mobile_number, with: /\A[a-zA-Z0-9+\- ]*\z/
	validates_format_of :mobile_number2, with: /\A[a-zA-Z0-9+\- ]*\z/
	validates_format_of :mobile_number3, with: /\A[a-zA-Z0-9+\- ]*\z/
	validates_format_of :mobile_number4, with: /\A[a-zA-Z0-9+\- ]*\z/
	validates_format_of :mobile_number5, with: /\A[a-zA-Z0-9+\- ]*\z/

	validates_presence_of :banned_reason, if: lambda { self.banned }, message: "should be provided"
	validates_presence_of :company_id_card_rejected_reason, if: lambda { self.company_id_card_status == "rejected" }, message: "should be provided"
	validates_presence_of :aadhar_rejected_reason, if: lambda { self.aadhar_status == "rejected" }, message: "should be provided"
	validates_presence_of :pan_card_rejected_reason, if: lambda { self.pan_card_status == "rejected" }, message: "should be provided"

	validates_presence_of :email
	validates_uniqueness_of :email, unless: lambda{ |user| user.email.blank? }
	validates_format_of :email,with: /\A(\S+)@(.+)\.(\S+)\z/, unless: lambda{ |user| user.email.blank? } 
	
	validates_uniqueness_of :old_email1, unless: lambda{ |user| user.old_email1.blank? }
	validates_format_of :old_email1,with: /\A(\S+)@(.+)\.(\S+)\z/, unless: lambda{ |user| user.old_email1.blank? } 

	validates_uniqueness_of :old_email2, unless: lambda{ |user| user.old_email2.blank? }
	validates_format_of :old_email2,with: /\A(\S+)@(.+)\.(\S+)\z/, unless: lambda{ |user| user.old_email2.blank? }

	# validates_presence_of :mobile_number
	# validates_uniqueness_of :mobile_number, unless: lambda{ |user| user.mobile_number.blank? }
	# validates_format_of :mobile_number,with: /\A^[6-9]\d{9}$\z/, message: "number invalid", unless: lambda{ |user| user.mobile_number.blank? } 

	validates_presence_of :firstname, unless: lambda{ |user| user.invited_by.present? }
	# validates_length_of :firstname, minimum: 3, unless: lambda{ |user| user.firstname.blank? }
	validates_format_of :firstname,with: /\A[a-zA-Z ]*\z/, message: "should contain only alphabets", unless: lambda{ |user| user.firstname.blank? } 

	validates_presence_of :lastname, unless: lambda{ |user| user.invited_by.present? }
	# validates_length_of :lastname, minimum: 3, unless: lambda{ |user| user.lastname.blank? }
	validates_format_of :lastname,with: /\A^[a-zA-Z ]*$\z/, message: "should contain only alphabets", unless: lambda{ |user| user.lastname.blank? } 

	 
	# validates_uniqueness_of :mobile_number, allow_blank: true, allow_nil: true 
 
	def email_in_use
		if User.where("email=? ",(self.old_email1 || self.old_email2)).first
			errors.add(:email, "There is already a user with this email")
		end
	end

	def aadhar_status_enum
		[['not uploaded'],['pending'],['accepted'],['rejected']]
	end#aadhar_status_enum

	def pan_card_status_enum
		[['not uploaded'],['pending'],['accepted'],['rejected']]
	end#aadhar_status_enum

	def company_id_card_status_enum
		[['not uploaded'],['pending'],['accepted'],['rejected']]
	end#aadhar_status_enum

  def emp_status_enum
    [['pending'],['in-review'],['completed']]
  end

	rails_admin do
		list do
			field :id 
			field :email do
				visible do
					 Current.toc.role.show_email == true
				end
			end
			field :company
			field :reset_password_sent_at
			field :remember_created_at
			field :sign_in_count
			field :current_sign_in_at
			field :last_sign_in_at
			field :current_sign_in_ip
			field :last_sign_in_at
			field :created_at
			field :updated_at
			field :firstname
			field :lastname
			field :confirmation_token
			field :confirmed_at
			field :confirmation_sent_at
			field :country
			field :country_code
			field :mobile_number do
				visible do
					 Current.toc.role.show_mobile_number == true
				end
			end
			field :mobile_number_verified
			field :duplicate_mobile_number
			field :mobile_number2 do
				visible do
					 Current.toc.role.show_mobile_number2 == true
				end
			end
			field :mobile_number2_verified
			field :mobile_number3 do
				visible do
					 Current.toc.role.show_mobile_number3 == true
				end
			end
			field :mobile_number3_verified
			field :mobile_number4 do
				visible do
					 Current.toc.role.show_mobile_number4 == true
				end
			end
			field :mobile_number4_verified
			field :mobile_number5 do
				visible do
					 Current.toc.role.show_mobile_number5 == true
				end
			end
			field :mobile_number5_verified
			field :unconfirmed_email
			field :address1
			field :address2
			field :city
			field :state
			field :postal_code
			field :last_response_at
			field :banned
			field :banned_reason
			field :account_suspended
			field :account_suspended_reason
			field :gauth_enabled
			field :role
			field :group
		end#list do    
		show do
			field :email do
				visible do
					 Current.toc.role.show_email == true
				end
			end
			field :old_email1 do
				visible do
					 Current.toc.role.show_email == true
				end
			end
			field :old_email2 do
				visible do
					 Current.toc.role.show_email == true
				end
			end            
			field :company
			field :firstname
			field :lastname
			field :country
			field :country_code
			field :duplicate_mobile_number 
			field :mobile_number do
				visible do
					 Current.toc.role.show_mobile_number == true
				end
			end
			field :mobile_number_verified
			field :mobile_number2 do
				visible do
					 Current.toc.role.show_mobile_number2 == true
				end
			end
			field :mobile_number2_verified
			field :mobile_number3 do
				visible do
					 Current.toc.role.show_mobile_number3 == true
				end
			end
			field :mobile_number3_verified
			field :mobile_number4 do
				visible do
					 Current.toc.role.show_mobile_number4 == true
				end
			end
			field :mobile_number4_verified
			field :mobile_number5 do
				visible do
					 Current.toc.role.show_mobile_number5 == true
				end
			end
			field :mobile_number5_verified
			field :unconfirmed_email
			field :address1
			field :address2
			field :city
			field :state
			field :postal_code
			field :banned
			field :banned_reason
			field :account_suspended
			field :account_suspended_reason     
			field :mobile_number_verified
			field :mobile_number2_verified
			field :mobile_number3_verified
			field :role
			field :group
			field :track_changes do 
				visible do
					Current.toc.role.role.eql?"superadmin"
				end
			end 
		end#show do
		edit do
			field :email do 
				visible do
					Current.toc.role.show_email == true
				end
			end
			field :old_email1 do
				read_only true
			end
			field :old_email2 do 
				read_only true
			end            
			# field :password
			# field :password_confirmation
			field :firstname
			field :lastname
			# field :middlename
			field :mobile_number_verified
			field :mobile_number2_verified
			field :mobile_number3_verified
			field :dob
			field :country do
				def render
					bindings[:view].render partial: 'country', locals: {field: self, form: bindings[:form]}
				end
			end
				
			field :state do
				def render
					bindings[:view].render partial: 'state', locals: {field: self, form: bindings[:form]}
				end
			end 
			field :city do
				def render
					bindings[:view].render partial: 'city', locals: {field: self, form: bindings[:form]}
				end
			end      
			field :country_code
			field :duplicate_mobile_number
			field :mobile_number do
				visible do
					 Current.toc.role.show_mobile_number == true
				end
			end
			field :mobile_number_verified
			field :mobile_number2 do
				visible do
					 Current.toc.role.show_mobile_number2 == true
				end
			end
			field :mobile_number2_verified
			field :mobile_number3 do
				visible do
					 Current.toc.role.show_mobile_number3 == true
				end
			end
			field :mobile_number3_verified
			field :mobile_number4 do
				visible do
					 Current.toc.role.show_mobile_number4 == true
				end
			end
			field :mobile_number4_verified
			field :mobile_number5 do
				visible do
					 Current.toc.role.show_mobile_number5 == true
				end
			end
			field :mobile_number5_verified
			field :unconfirmed_email do 
				read_only true
			end
						
			field :address1
			field :address2
			field :postal_code
			field :banned
			field :banned_reason
			field :account_suspended
			field :account_suspended_reason			
			field :emp_status

			field :aadhar_front
			field :aadhar_back
			field :admin_verified_aadhar_front
			field :admin_verified_aadhar_back
			field :aadhar_number
			field :aadhar_status
			field :aadhar_rejected_reason

			field :pan_card
			field :admin_verified_pan_card
			field :pan_number
			field :pan_card_status
			field :pan_card_rejected_reason

			field :company_id_card
			field :company_id_card_status
			field :company_id_card_rejected_reason
			field :kyc_verified
		end
	end#rails_admin

	def change_email
		if self.email_previously_changed? && persisted?
			changes = self.saved_changes
			if self.old_email1.nil?
				self.old_email1 = changes[:email][0]
				self.unconfirmed_email = self.email
				@send_email = self.old_email1
			elsif self.email != self.old_email1 && self.old_email1.present? && self.old_email2.nil?
				self.old_email2 = changes[:email][0]
				self.unconfirmed_email = self.email
				@send_email = self.old_email2
			end
			self.confirmation_token = SecureRandom.base58(24)
			self.confirmed_at = nil
			self.executed = true
			self.save!
			@id  = self.id
			UserMailer.change_email_request(@id,self.email,self.confirmation_token,@send_email).deliver_later
		end
	end#change_email

	def send_info
		if banned_previously_changed? && persisted?
			UserMailer.user_blocked(self,self.banned,banned_reason).deliver_later
		end#block_user

    if account_suspended_previously_changed? && persisted?
      UserMailer.account_suspended(self,self.account_suspended,account_suspended_reason).deliver_later
    end#block_user

		if (aadhar_status_previously_changed? and persisted?) && (aadhar_status == "accepted" or aadhar_status == "rejected")
			UserMailer.user_aadhar_status_mail(self,aadhar_status,aadhar_rejected_reason).deliver_later
		end#address1_proof

		if (pan_card_status_previously_changed? and persisted?) && (pan_card_status == "accepted" or pan_card_status == "rejected")
			UserMailer.user_pan_card_status_mail(self,pan_card_status,pan_card_rejected_reason).deliver_later
		end#id_proof

		if (company_id_card_status_previously_changed? and persisted?) && (company_id_card_status == "accepted" or company_id_card_status == "rejected")
			UserMailer.user_company_id_card_status_mail(self,company_id_card_status,company_id_card_rejected_reason).deliver_later
		end#id_proof

    if kyc_verified == true and (kyc_verified_previously_changed? && persisted?)
      UserMailer.profile_verified(self).deliver_later
    end
	end#send_info

	def upload_proofs

		if (self.saved_change_to_admin_verified_aadhar_front? || self.saved_change_to_admin_verified_aadhar_back?) && self.aadhar_status != "accepted"
			self.aadhar_status = "pending"
		end#admin_verified_address1_proof
		if (self.saved_change_to_admin_verified_pan_card? ) && self.pan_card_status != "accepted"
			self.pan_card_status = "pending"
		end

		current_toc = Current.toc.id rescue nil
		if current_toc.present?
  		if self.saved_change_to_admin_verified_aadhar_front?
        UserMailer.aadhar_upload(self,"front",current_toc,"admin").deliver_later
  		end#if self.saved_change_to_admin_verified_aadhar_front?

  		if self.saved_change_to_admin_verified_aadhar_back?
  			UserMailer.aadhar_upload(self,"back",current_toc,"admin").deliver_later
  		end#if self.saved_change_to_admin_verified_aadhar_front?

  		if self.saved_change_to_admin_verified_pan_card?
  			UserMailer.pan_card_upload(self,"front",current_toc,"admin").deliver_later
  		end#if self.saved_change_to_pan_card_file_name?

  		if self.saved_change_to_aadhar_front?
  			UserMailer.aadhar_upload(self,"front",current_toc,"user").deliver_later
  		end#if self.saved_change_to_aadhar_front?

  		if self.saved_change_to_aadhar_back?
  			UserMailer.aadhar_upload(self,"back",current_toc,"user").deliver_later
  		end#if self.saved_change_to_aadhar_back?

  		if self.saved_change_to_company_id_card?
  			UserMailer.company_id_card_upload(self,current_toc).deliver_later
  		end#if self.saved_change_to_company_id_card?

  		if self.saved_change_to_pan_card?
  			UserMailer.pan_card_upload(self,"front",current_toc,"user").deliver_later
  		end#if self.saved_change_to_pan_card?
		end#current_toc.present?

		self.executed = true
		self.save!(validate:false) if self.persisted?
	end#upload_proofs_status

  def user_kyc_check_update
    if Current.toc.present?
      #if  pan card  modified
      if (pan_card_status_previously_changed? && persisted?) && self.pan_card_status =="accepted"
        @employee_stat = EmployeeKycStat.new(:toc_id=>Current.toc.id,:user_id=>self.id)
        @employee_stat.action_performed ="Pan Card accepted"
        @employee_stat.save!
      elsif (pan_card_status_previously_changed? && persisted?) && self.pan_card_status =="rejected"
        @employee_stat = EmployeeKycStat.new(:toc_id=>Current.toc.id,:user_id=>self.id)
        @employee_stat.action_performed ="Pan Card rejected"
        @employee_stat.save!
      end
      # if aadhar modified
      if (aadhar_status_previously_changed? && persisted?) && self.aadhar_status =="accepted"
        @employee_stat = EmployeeKycStat.new(:toc_id=>Current.toc.id,:user_id=>self.id)
        @employee_stat.action_performed ="Aadhar accepted"
        @employee_stat.save!
      elsif (aadhar_status_previously_changed? && persisted?) && self.aadhar_status =="rejected"
        @employee_stat = EmployeeKycStat.new(:toc_id=>Current.toc.id,:user_id=>self.id)
        @employee_stat.action_performed ="Aadhar rejected"
        @employee_stat.save!
      end
      #if Company ID Card modified
      if (company_id_card_status_previously_changed? && persisted?) && self.company_id_card_status =="accepted"
        @employee_stat = EmployeeKycStat.new(:toc_id=>Current.toc.id,:user_id=>self.id)
        @employee_stat.action_performed ="Company ID Card accepted"
        @employee_stat.save!
      elsif (company_id_card_status_previously_changed? && persisted?) && self.company_id_card_status =="rejected"
        @employee_stat = EmployeeKycStat.new(:toc_id=>Current.toc.id,:user_id=>self.id)
        @employee_stat.action_performed ="Company ID Card rejected"
        @employee_stat.save!
      end
      # if kyc verified
      if (kyc_verified_previously_changed? && persisted?) && self.kyc_verified ==true
        @employee_stat = EmployeeKycStat.new(:toc_id=>Current.toc.id,:user_id=>self.id)
        @employee_stat.action_performed ="KYC verified set to true"
        @employee_stat.save!
      elsif (kyc_verified_previously_changed? && persisted?) && self.kyc_verified ==false
        @employee_stat = EmployeeKycStat.new(:toc_id=>Current.toc.id,:user_id=>self.id)
        @employee_stat.action_performed ="KYC verified set to false"
        @employee_stat.save!
      end
    end#Current.toc
  end#user_kyc_check_update
	##send mail to admin after uploading address1 proof docs, id proof docs

	def track_changes_in_table
		if Current.toc.present? && self.saved_changes.present? 
			user = User.find(self.id)
			version = PaperTrail::Version.where('item_type=? and item_id=? and whodunnit=?','User',self.id,Current.toc.id.to_s).last.object_changes rescue nil
			if version.present?
				version_data = version.gsub("\n"," ").gsub("--- ","")
				message = "Admin #{Current.toc.email} with id '#{Current.toc.id}' updated the following fields of User '#{user.id}'"+' '+ version_data
				subject = "Admin  with id '#{Current.toc.id}', role #{Current.toc.role.role} updated USER table"
				latest_changes = []
				latest_changes << version_data
				latest_changes << Current.toc.email[0..3]+""+Current.toc.id.to_s+" "+Time.zone.now.strftime("%d/%m/%Y %H:%M")
				all_changes = (user.track_changes + latest_changes).flatten
				user.track_changes = all_changes
				user.executed = true
				user.save(touch: false)
				UserMailer.track_changes(message,subject).deliver_later
			end#version.present?
		end#Current.toc.present? && self.saved_changes.present? 
	end#track_changes_in_table  
end
