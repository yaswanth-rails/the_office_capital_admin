# app/models/job_applicant.rb
class JobApplicant < ApplicationRecord
  include Current
  attr_accessor :current_toc  
  has_paper_trail on: [:update, :destroy], ignore: [:track_changes,:updated_at,:job_description], if: Proc.new { Current.toc }
  attr_accessor :executed
  after_update :track_changes_in_table, unless: :executed
  after_update :send_info
  has_many :job_applications
  has_many :interview_round_statuses

  validates :email, presence: true, uniqueness: true
  validates :phone, presence: true, uniqueness: true

  mount_uploader :aadhar, JobUploader
  mount_uploader :resume, ResumeUploader
  mount_uploader :exp_document, JobUploader

  validates_format_of :full_name, :with=> /\A[a-zA-Z0-9. ]*\z/
  validates_format_of :phone, :with=> /\A[0-9]*\z/
  validates_format_of :percentage, :with=> /\A[0-9]*\z/
  validates_format_of :exp_description, :with=> /\A[a-zA-Z0-9. ]*\z/
  validates_format_of :no_of_years_exp, :with=> /\A[a-zA-Z0-9. ]*\z/
  validates_format_of :passed_out_year, :with=> /\A[a-zA-Z0-9. ]*\z/
  validates_format_of :aadhar_number, :with=> /\A[0-9]*\z/

  def gender_enum
    [['male'],['female']]
  end#aadhar_status_enum

  def aadhar_status_enum
    [['pending'],['accepted'],['rejected']]
  end#aadhar_status_enum

  def resume_status_enum
    [['pending'],['accepted'],['rejected']]
  end#resume_status_enum

  rails_admin do
    edit do
      field :email do
        read_only true
      end
      field :phone do
        read_only true
      end
      field :full_name do
        read_only true
      end
      field :gender
      field :qualification
      field :prev_exp
      field :exp_description
      field :no_of_years_exp
      field :exp_document
      field :exp_document_status
      field :exp_document_rejected_reason
      field :exp_document_status_alert
      field :passed_out_year
      field :aadhar_number
      field :aadhar
      field :aadhar_status
      field :aadhar_rejected_reason
      field :aadhar_status_alert
      field :resume
      field :resume_status
      field :resume_rejected_reason
      field :resume_status_alert
      field :verified
      field :verified_alert
      field :banned
      field :banned_reason
    end

    list do
      field :id
      field :email
      field :phone
      field :full_name
      field :created_at
      field :updated_at
      field :gender
      field :last_active_at
      field :otp_secret
      field :auth_token
      field :qualification
      field :prev_exp
      field :exp_description
      field :no_of_years_exp
      field :exp_document
      field :exp_document_status
      field :exp_document_rejected_reason
      field :exp_document_status_alert
      field :passed_out_year
      field :aadhar_number
      field :aadhar
      field :aadhar_status
      field :aadhar_rejected_reason
      field :aadhar_status_alert
      field :resume
      field :resume_status
      field :resume_rejected_reason
      field :resume_status_alert
      field :verified
      field :verified_alert
      field :banned
      field :banned_reason

    end
  end

  def send_info
    if banned_previously_changed? && persisted?
      JobMailer.user_blocked(self,self.banned,banned_reason).deliver_later
    end#block_user

    if (aadhar_status_alert and aadhar_status_previously_changed? and persisted?) && (aadhar_status == "accepted" or aadhar_status == "rejected")
      JobMailer.user_aadhar_status_mail(self,aadhar_status,aadhar_rejected_reason).deliver_later
    end#address1_proof

    if (resume_status_alert and resume_status_previously_changed? and persisted?) && (resume_status == "accepted" or resume_status == "rejected")
      JobMailer.user_resume_status_mail(self,resume_status,resume_rejected_reason).deliver_later
    end#id_proof

    if (exp_document_status_alert and exp_document_status_previously_changed? and persisted?) && (exp_document_status == "accepted" or exp_document_status == "rejected")
      JobMailer.user_exp_document_status_mail(self,exp_document_status,exp_document_rejected_reason).deliver_later
    end#id_proof

    if verified == true and (verified_alert and verified_previously_changed? && persisted?)
      JobMailer.profile_verified(self).deliver_later
    end
  end#send_info

  def track_changes_in_table
    if Current.toc.present? && self.saved_changes.present? 
      row = JobApplicant.find(self.id)
      version = PaperTrail::Version.where('item_type=? and item_id=? and whodunnit=?','JobApplicant',self.id,Current.toc.id.to_s).last.object_changes rescue nil
      if version.present?
        version_data = version.gsub("\n"," ").gsub("--- ","")
        message = "Admin #{Current.toc.email} with id '#{Current.toc.id}' updated the following fields of JobApplicant '#{row.id}'"+' '+version_data
        subject = "Admin  with id '#{Current.toc.id}', role #{Current.toc.role.role} updated JobApplicant table"
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
