class Ability
  include CanCan::Ability

  def initialize(toc)
    if toc
      can :access, :rails_admin
      can :dashboard 
      can [:read], :dashboard
      role = toc.role
      if toc.has_role? :superadmin
        can :manage, :all
      elsif toc.has_role? :employee
        read_array = Toc.get_read_privileges(toc.id)
        create_array = Toc.get_create_privileges(toc.id)
        update_array = Toc.get_update_privileges(toc.id)
        delete_array = Toc.get_delete_privileges(toc.id)
        export_array = Toc.get_export_privileges(toc.id)
        can :export, :export_array
        
        can :read, read_array
        can :create, create_array 
        can :update, update_array
        can :destroy, delete_array

        can :show_backup_code, [User] if role.show_backup_code
      	can :loggedin_ips, [User]
        can :sub_section_kyc,[User] if role.can_edit_kyc_details
        can :pan_card_edit,[User] if role.can_update_pan_card
        can :aadhar_edit,[User] if role.can_update_aadhar
        can :company_id_card_edit,[User] if role.can_update_company_id_card
        can :change_proof_status,[User] if role.can_edit_kyc_details
        can :kyc_verified_edit,[User] if role.can_update_kyc_verified
        can :pending_kyc_users,[User] if role.can_update_pending_kyc_users
        can :pending_kyc_user_update,[User] if role.can_update_pending_kyc_users
        can :unverified_bank_accounts,[BankAccount] if role.can_update_unverified_bank_accounts
        can :unverified_bank_acc_update,[BankAccount] if role.can_update_unverified_bank_accounts
        can :statement,[User,Wallet,Company] if role.statement
        can :group_bookings, [BookingGroup] if role.group_bookings
        can :company_users, [Company] if role.company_users
        can :group_users, [Company] if role.group_users
        can :refund, [Booking] if role.process_refund
        can :process_refund, [Booking] if role.process_refund
        can :booking_group_refund, [BookingGroup] if role.process_refund
        can :process_booking_group_refund, [BookingGroup] if role.process_refund
      elsif toc.has_role? :admin
        read_array=Toc.get_read_privileges(toc.id)
        create_array=Toc.get_create_privileges(toc.id)
        update_array=Toc.get_update_privileges(toc.id)
        delete_array=Toc.get_delete_privileges(toc.id)
        export_array=Toc.get_export_privileges(toc.id)
        can :export, :export_array
        can :read, read_array
        can :create, create_array
        can :update, update_array
        can :destroy, delete_array
        can :loggedin_ips, [User]
        can :show_backup_code, [User] if role.show_backup_code
        can :sub_section_kyc,[User] if role.can_edit_kyc_details
        can :pan_card_edit,[User] if role.can_update_pan_card
        can :aadhar_edit,[User] if role.can_update_aadhar
        can :company_id_card_edit,[User] if role.can_update_company_id_card
        can :change_proof_status,[User] if role.can_edit_kyc_details
        can :kyc_verified_edit,[User] if role.can_update_kyc_verified
        can :pending_kyc_users,[User] if role.can_update_pending_kyc_users
        can :pending_kyc_user_update,[User] if role.can_update_pending_kyc_users
        can :unverified_bank_accounts,[BankAccount] if role.can_update_unverified_bank_accounts
        can :unverified_bank_acc_update,[BankAccount] if role.can_update_unverified_bank_accounts
        can :statement,[User,Wallet,Company] if role.statement
        can :group_bookings, [BookingGroup] if role.group_bookings
        can :company_users, [Company] if role.company_users
        can :group_users, [Company] if role.group_users
        can :refund, [Booking] if role.process_refund
        can :process_refund, [Booking] if role.process_refund
        can :booking_group_refund, [BookingGroup] if role.process_refund
        can :process_booking_group_refund, [BookingGroup] if role.process_refund
      end
    end#if toc
  end
end
