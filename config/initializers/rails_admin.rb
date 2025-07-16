require Rails.root.join('lib', 'rails_admin_loggedin_ips.rb')
require Rails.root.join('lib', 'rails_admin_online_users.rb')
require Rails.root.join('lib', 'rails_admin_company_users.rb')
require Rails.root.join('lib', 'rails_admin_group_users.rb')
require Rails.root.join('lib', 'rails_admin_banned_users.rb')
require Rails.root.join('lib', 'rails_admin_statement.rb')
require Rails.root.join('lib', 'rails_admin_group_bookings.rb')
require Rails.root.join('lib', 'rails_admin_sub_section_kyc.rb')
require Rails.root.join('lib', 'rails_admin_pan_card_edit.rb')
require Rails.root.join('lib', 'rails_admin_aadhar_edit.rb')
require Rails.root.join('lib', 'rails_admin_company_id_card_edit.rb')
require Rails.root.join('lib', 'rails_admin_change_proof_status.rb')
require Rails.root.join('lib', 'rails_admin_kyc_verified_edit.rb')
require Rails.root.join('lib', 'rails_admin_pending_kyc_users.rb')
require Rails.root.join('lib', 'rails_admin_pending_kyc_user_update.rb')
require Rails.root.join('lib', 'rails_admin_kyc_update_for_withdraws.rb')
require Rails.root.join('lib', 'rails_admin_unverified_bank_accounts.rb')
require Rails.root.join('lib', 'rails_admin_unverified_bank_acc_update.rb')
require Rails.root.join('lib', 'rails_admin_job_applicant_kyc.rb')
require Rails.root.join('lib', 'rails_admin_job_applicant_aadhar_edit.rb')
require Rails.root.join('lib', 'rails_admin_job_applicant_resume_edit.rb')
require Rails.root.join('lib', 'rails_admin_job_applicant_exp_document_edit.rb')
require Rails.root.join('lib', 'rails_admin_job_applicant_change_proof_status.rb')
require Rails.root.join('lib', 'rails_admin_job_applicant_verified_edit.rb')
require Rails.root.join('lib', 'rails_admin_interview_rounds.rb')
require Rails.root.join('lib', 'rails_admin_questions.rb')
require Rails.root.join('lib', 'rails_admin_answers.rb')
require Rails.root.join('lib', 'rails_admin_job_applications.rb')
require Rails.root.join('lib', 'rails_admin_refund.rb')
require Rails.root.join('lib', 'rails_admin_process_refund.rb')
require Rails.root.join('lib', 'rails_admin_booking_group_refund.rb')
require Rails.root.join('lib', 'rails_admin_process_booking_group_refund.rb')
# require Rails.root.join('lib', 'rails_admin_show_backup_code.rb')
require Rails.root.join('lib', 'rails_admin', 'config','actions', 'export.rb')

RailsAdmin::Config::Actions.register(RailsAdmin::Config::Actions::Export)
RailsAdmin.config do |config|
  config.asset_source = :sprockets
  config.authorize_with do
    redirect_to main_app.root_path unless current_toc
  end
  ### Popular gems integration

  # == Devise ==
  config.parent_controller = 'ApplicationController'
  config.main_app_name = ['TheCapitalOffice™', '']
  config.authenticate_with do
    warden.authenticate! scope: :toc
  end
  config.current_user_method(&:current_toc)

  ## == Cancan ==
  config.authorize_with :cancancan #TODO add cancancan to rails_admin config

  ## == PaperTrail ==
  config.audit_with :paper_trail, 'Toc', 'PaperTrail::Version' # PaperTrail >= 3.0.0

  config.default_items_per_page = 50
  config.compact_show_view = false
  config.default_hidden_fields = []

 

module RailsAdmin
    module Config
      module Actions
        class LoggedinIps < RailsAdmin::Config::Actions::Base
          RailsAdmin::Config::Actions.register(self)
        end
      end
    end
  end     

  module RailsAdmin
    module Config
      module Actions
        class OnlineUsers < RailsAdmin::Config::Actions::Base
          RailsAdmin::Config::Actions.register(self)
        end
      end
    end
  end
  module RailsAdmin
    module Config
      module Actions
        class CompanyUsers < RailsAdmin::Config::Actions::Base
          RailsAdmin::Config::Actions.register(self)
        end
      end
    end
  end

  module RailsAdmin
    module Config
      module Actions
        class GroupUsers < RailsAdmin::Config::Actions::Base
          RailsAdmin::Config::Actions.register(self)
        end
      end
    end
  end

  module RailsAdmin
    module Config
      module Actions
        class Statement < RailsAdmin::Config::Actions::Base
          RailsAdmin::Config::Actions.register(self)
        end
      end
    end
  end

  module RailsAdmin
    module Config
      module Actions
        class GroupBookings < RailsAdmin::Config::Actions::Base
          RailsAdmin::Config::Actions.register(self)
        end
      end
    end
  end

  module RailsAdmin
    module Config
      module Actions
        class BannedUsers < RailsAdmin::Config::Actions::Base
          RailsAdmin::Config::Actions.register(self)
        end
      end
    end
  end

  module RailsAdmin
    module Config
      module Actions
        class ShowBackupCode < RailsAdmin::Config::Actions::Base
          RailsAdmin::Config::Actions.register(self)
        end
      end
    end
  end

  module RailsAdmin
    module Config
      module Actions
        class SubSectionKyc < RailsAdmin::Config::Actions::Base
          RailsAdmin::Config::Actions.register(self)
        end
      end
    end
  end
  module RailsAdmin
    module Config
      module Actions
        class PanCardEdit < RailsAdmin::Config::Actions::Base
          RailsAdmin::Config::Actions.register(self)
        end
      end
    end
  end
  module RailsAdmin
    module Config
      module Actions
        class AadharEdit < RailsAdmin::Config::Actions::Base
          RailsAdmin::Config::Actions.register(self)
        end
      end
    end
  end
  module RailsAdmin
    module Config
      module Actions
        class CompanyIdCardEdit < RailsAdmin::Config::Actions::Base
          RailsAdmin::Config::Actions.register(self)
        end
      end
    end
  end
  module RailsAdmin
    module Config
      module Actions
        class ChangeProofStatus < RailsAdmin::Config::Actions::Base
          RailsAdmin::Config::Actions.register(self)
        end
      end
    end
  end
  module RailsAdmin
    module Config
      module Actions
        class KycVerifiedEdit < RailsAdmin::Config::Actions::Base
          RailsAdmin::Config::Actions.register(self)
        end
      end
    end
  end
  module RailsAdmin
    module Config
      module Actions
        class PendingKycUsers < RailsAdmin::Config::Actions::Base
          RailsAdmin::Config::Actions.register(self)
        end
      end
    end
  end

  module RailsAdmin
    module Config
      module Actions
        class PendingKycUserUpdate < RailsAdmin::Config::Actions::Base
          RailsAdmin::Config::Actions.register(self)
        end
      end
    end
  end

  module RailsAdmin
    module Config
      module Actions
        class KycUpdateForWithdraws < RailsAdmin::Config::Actions::Base
          RailsAdmin::Config::Actions.register(self)
        end
      end
    end
  end

  module RailsAdmin
    module Config
      module Actions
        class JobApplicantAadharEdit < RailsAdmin::Config::Actions::Base
          RailsAdmin::Config::Actions.register(self)
        end
      end
    end
  end

  module RailsAdmin
    module Config
      module Actions
        class JobApplicantResumeEdit < RailsAdmin::Config::Actions::Base
          RailsAdmin::Config::Actions.register(self)
        end
      end
    end
  end

  module RailsAdmin
    module Config
      module Actions
        class JobApplicantExpDocumentEdit < RailsAdmin::Config::Actions::Base
          RailsAdmin::Config::Actions.register(self)
        end
      end
    end
  end

  module RailsAdmin
    module Config
      module Actions
        class JobApplicantKyc < RailsAdmin::Config::Actions::Base
          RailsAdmin::Config::Actions.register(self)
        end
      end
    end
  end

  module RailsAdmin
    module Config
      module Actions
        class JobApplicantChangeProofStatus < RailsAdmin::Config::Actions::Base
          RailsAdmin::Config::Actions.register(self)
        end
      end
    end
  end

  module RailsAdmin
    module Config
      module Actions
        class JobApplicantVerifiedEdit < RailsAdmin::Config::Actions::Base
          RailsAdmin::Config::Actions.register(self)
        end
      end
    end
  end

  module RailsAdmin
    module Config
      module Actions
        class InterviewRounds < RailsAdmin::Config::Actions::Base
          RailsAdmin::Config::Actions.register(self)
        end
      end
    end
  end

  module RailsAdmin
    module Config
      module Actions
        class Questions < RailsAdmin::Config::Actions::Base
          RailsAdmin::Config::Actions.register(self)
        end
      end
    end
  end

  module RailsAdmin
    module Config
      module Actions
        class Answers < RailsAdmin::Config::Actions::Base
          RailsAdmin::Config::Actions.register(self)
        end
      end
    end
  end

  module RailsAdmin
    module Config
      module Actions
        class JobApplications < RailsAdmin::Config::Actions::Base
          RailsAdmin::Config::Actions.register(self)
        end
      end
    end
  end

  module RailsAdmin
    module Config
      module Actions
        class Refund < RailsAdmin::Config::Actions::Base
          RailsAdmin::Config::Actions.register(self)
        end
      end
    end
  end

  module RailsAdmin
    module Config
      module Actions
        class ProcessRefund < RailsAdmin::Config::Actions::Base
          RailsAdmin::Config::Actions.register(self)
        end
      end
    end
  end

  module RailsAdmin
    module Config
      module Actions
        class BookingGroupRefund < RailsAdmin::Config::Actions::Base
          RailsAdmin::Config::Actions.register(self)
        end
      end
    end
  end

  module RailsAdmin
    module Config
      module Actions
        class ProcessBookingGroupRefund < RailsAdmin::Config::Actions::Base
          RailsAdmin::Config::Actions.register(self)
        end
      end
    end
  end

  module RailsAdmin
    module Config
      module Actions
        class UnverifiedBankAccounts < RailsAdmin::Config::Actions::Base
          RailsAdmin::Config::Actions.register(self)
        end
      end
    end
  end

  module RailsAdmin
    module Config
      module Actions
        class UnverifiedBankAccUpdate < RailsAdmin::Config::Actions::Base
          RailsAdmin::Config::Actions.register(self)
        end
      end
    end
  end

  config.actions do
    dashboard                     # mandatory
    index                         # mandatory
    new do
      except  ['Company','JobAnswer','ContactSubmission','Booking','BookingGroup','ExternalGuest','Group','JobApplication','JobApplicant','Wallet','WalletHistory','Deposit','UserCouponUse','Withdraw','Review','PaperTrail::Version','PaperTrail::Association']
    end

    loggedin_ips do
      visible do
        bindings[:abstract_model].model.to_s == "User"
      end
    end        

    online_users do
      visible do
        bindings[:abstract_model].model.to_s == "User"
      end
    end

    company_users do
      visible do
        bindings[:abstract_model].model.to_s == "Company"
      end
    end

    group_users do
      visible do
        bindings[:abstract_model].model.to_s == "Group"
      end
    end
    
    banned_users do
      visible do
        bindings[:abstract_model].model.to_s == "User"
      end
    end

    show_backup_code do
      visible do
        bindings[:abstract_model].model.to_s == "User"
      end
    end

    sub_section_kyc do
      visible do
        bindings[:abstract_model].model.to_s == "User"
      end 
    end
    pan_card_edit do
      visible do
        bindings[:abstract_model].model.to_s == "User"
      end 
    end
    aadhar_edit do
      visible do
        bindings[:abstract_model].model.to_s == "User"
      end 
    end
    company_id_card_edit do
      visible do
        bindings[:abstract_model].model.to_s == "User"
      end 
    end
    change_proof_status do
      visible do
        bindings[:abstract_model].model.to_s == "User"
      end 
    end
    kyc_verified_edit do
      visible do
        bindings[:abstract_model].model.to_s == "User"
      end 
    end
    pending_kyc_users do
      visible do
        (bindings[:abstract_model].model.to_s == "User")
      end 
    end
    pending_kyc_user_update do
      visible do
        (bindings[:abstract_model].model.to_s == "User")
      end 
    end
    kyc_update_for_withdraws do
      visible do
        bindings[:abstract_model].model.to_s == "Withdraw"
      end
    end
    unverified_bank_accounts do
      visible do
        bindings[:abstract_model].model.to_s == "BankAccount"
      end 
    end
    unverified_bank_acc_update do
      visible do
        bindings[:abstract_model].model.to_s == "BankAccount"
      end 
    end
    group_bookings do
      visible do
        bindings[:abstract_model].model.to_s == "BookingGroup"
      end
    end
    job_applicant_kyc do
      visible do
        bindings[:abstract_model].model.to_s == "JobApplicant"
      end
    end
    job_applicant_aadhar_edit do
      visible do
        bindings[:abstract_model].model.to_s == "JobApplicant"
      end
    end
    job_applicant_resume_edit do
      visible do
        bindings[:abstract_model].model.to_s == "JobApplicant"
      end
    end
    job_applicant_exp_document_edit do
      visible do
        bindings[:abstract_model].model.to_s == "JobApplicant"
      end
    end
    job_applicant_change_proof_status do
      visible do
        bindings[:abstract_model].model.to_s == "JobApplicant"
      end 
    end
    job_applicant_verified_edit do
      visible do
        bindings[:abstract_model].model.to_s == "JobApplicant"
      end 
    end
    interview_rounds do
      visible do
        bindings[:abstract_model].model.to_s == "JobApplication"
      end 
    end
    questions do
      visible do
        bindings[:abstract_model].model.to_s == "Job"
      end
    end
    answers do
      visible do
        bindings[:abstract_model].model.to_s == "JobApplication"
      end
    end
    job_applications do
      visible do
        bindings[:abstract_model].model.to_s == "Job"
      end
    end
    refund do
      visible do
        bindings[:abstract_model].model.to_s == "Booking"
      end
    end
    process_refund do
      visible do
        bindings[:abstract_model].model.to_s == "Booking"
      end
    end
    booking_group_refund do
      visible do
        bindings[:abstract_model].model.to_s == "BookingGroup"
      end
    end
    process_booking_group_refund do
      visible do
        bindings[:abstract_model].model.to_s == "BookingGroup"
      end
    end

    statement
    export
    # bulk_delete
    show
    edit do
      except ['Group','JobAnswer','ContactSubmission','UserCouponUse','WalletHistory','EmployeeKycStat','Deposit','ExternalGuest','LoginHistory','Review','PaperTrail::Version','PaperTrail::Association']
    end
    # delete do
    #   only ['JobQuestionAssignment']
    # end
    history_show
  end
end
