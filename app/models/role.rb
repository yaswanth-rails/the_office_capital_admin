class Role < ApplicationRecord
  include Current
  attr_accessor :current_toc  
  has_paper_trail on: [:update, :destroy], ignore: [:track_changes,:updated_at], if: Proc.new { Current.toc }
  attr_accessor :executed
  after_update :track_changes_in_table, unless: :executed

	belongs_to :toc
	serialize :read_privileges, Array
	serialize :create_privileges, Array
	serialize :update_privileges, Array
  serialize :delete_privileges, Array
	serialize :history_privileges, Array

  def role_enum
    %w[superadmin admin employee]
  end
  def read_privileges_enum
    %w[Amenity BankAccount Booking BookingGroup Company Coupon ContactSubmission Deposit EmployeeKycStat Equipment ExternalGuest Group Job JobAnswer JobApplication JobQuestion JobQuestionAssignment InterviewRound InterviewRoundStatus JobApplicant Location LoginHistory Review Street User UserCouponUse Wallet WalletHistory Withdraw Workspace WorkspaceAmenity WorkspaceEquipment WorkspaceTiming WorkspaceType]
  end
  def create_privileges_enum
    %w[Amenity BankAccount Booking BookingGroup Company Coupon ContactSubmission Deposit EmployeeKycStat Equipment ExternalGuest Group Job JobAnswer JobApplication JobQuestion JobQuestionAssignment InterviewRound InterviewRoundStatus JobApplicant Location LoginHistory Review Street User UserCouponUse Wallet WalletHistory Withdraw Workspace WorkspaceAmenity WorkspaceEquipment WorkspaceTiming WorkspaceType]
  end
  def update_privileges_enum
    %w[Amenity BankAccount Booking BookingGroup Company Coupon ContactSubmission Deposit EmployeeKycStat Equipment ExternalGuest Group Job JobAnswer JobApplication JobQuestion JobQuestionAssignment InterviewRound InterviewRoundStatus JobApplicant Location LoginHistory Review Street User UserCouponUse Wallet WalletHistory Withdraw Workspace WorkspaceAmenity WorkspaceEquipment WorkspaceTiming WorkspaceType]
  end       
  def delete_privileges_enum
    %w[Amenity BankAccount Booking BookingGroup Company Coupon ContactSubmission Deposit EmployeeKycStat Equipment ExternalGuest Group Job JobAnswer JobApplication JobQuestion JobQuestionAssignment InterviewRound InterviewRoundStatus JobApplicant Location LoginHistory Review Street User UserCouponUse Wallet WalletHistory Withdraw Workspace WorkspaceAmenity WorkspaceEquipment WorkspaceTiming WorkspaceType]
  end
  def history_privileges_enum
    %w[Amenity BankAccount Booking BookingGroup Company Coupon ContactSubmission Deposit EmployeeKycStat Equipment ExternalGuest Group Job JobAnswer JobApplication JobQuestion JobQuestionAssignment InterviewRound InterviewRoundStatus JobApplicant Location LoginHistory Review Street User UserCouponUse Wallet WalletHistory Withdraw Workspace WorkspaceAmenity WorkspaceEquipment WorkspaceTiming WorkspaceType]
  end

  # def export_privileges_enum
  #   %w[ContactSubmission LoginHistory User]
  # end  
  
  rails_admin do
    edit do
      field :toc
      field :role
      field :read_privileges do
        render do
          bindings[:form].select( "read_privileges", bindings[:object].read_privileges_enum, {}, { multiple: true })
        end
      end
      field :create_privileges do
        render do
          bindings[:form].select( "create_privileges", bindings[:object].create_privileges_enum, {}, { multiple: true })
        end
      end
      field :update_privileges do
        render do
          bindings[:form].select( "update_privileges", bindings[:object].update_privileges_enum, {}, { multiple: true })
        end
      end           
      field :delete_privileges do
        render do
          bindings[:form].select( "delete_privileges", bindings[:object].delete_privileges_enum, {}, { multiple: true })
        end
      end
      # field :history_privileges do
      #   render do
      #     bindings[:form].select( "history_privileges", bindings[:object].history_privileges_enum, {}, { multiple: true })
      #   end
      # end
      # field :export_privileges do
      #   render do
      #     bindings[:form].select( "export_privileges", bindings[:object].export_privileges_enum, {}, { :multiple => true })
      #   end
      # end
      field :show_email
      field :show_mobile_number
      field :show_mobile_number2
      field :show_mobile_number3
      field :show_mobile_number4
      field :show_mobile_number5    
      field :show_backup_code
      field :can_update_aadhar
      field :can_update_pan_card
      field :can_update_company_id_card
      field :can_update_kyc_verified
      field :can_edit_kyc_details
      field :can_update_pending_kyc_users
      field :can_update_unverified_bank_accounts
      field :statement
      field :group_bookings
      field :company_users
      field :group_users
      field :process_refund
    end
  end#rails_admin 

  def track_changes_in_table
    if Current.toc.present? && self.saved_changes.present? 
      row = Role.find(self.id)
      version = PaperTrail::Version.where('item_type=? and item_id=? and whodunnit=?','Role',self.id,Current.toc.id.to_s).last.object_changes rescue nil
      if version.present?
        version_data = version.gsub("\n"," ").gsub("--- ","")
        message = "Admin #{Current.toc.email} with id '#{Current.toc.id}' updated the following fields of Role '#{row.id}'"+' '+version_data
        subject = "Admin  with id '#{Current.toc.id}', role #{Current.toc.role.role} updated Role table"
        latest_changes = []
        latest_changes << version_data
        latest_changes << Current.toc.email[0..3]+""+Current.toc.id.to_s+" "+Time.zone.now.strftime("%d/%m/%Y %H:%M")
        all_changes = (row.track_changes + latest_changes).flatten
        row.track_changes = all_changes
        row.executed = true
        row.save!
        UserMailer.track_changes(message,subject).deliver_later
      end#version.present?
    end#Current.toc.present? && self.saved_changes.present? 
  end#track_changes_in_table        
  
end

