class JobApplication< ApplicationRecord
  include Current
  attr_accessor :current_toc  
  has_paper_trail on: [:update, :destroy], ignore: [:track_changes,:updated_at], if: Proc.new { Current.toc }
  attr_accessor :executed
  after_update :track_changes_in_table, unless: :executed
  after_update :send_info

  has_many :interview_round_statuses
  belongs_to :job
  belongs_to :job_applicant, optional: true
  has_many :job_answers, inverse_of: :job_application#, dependent: :destroy
  accepts_nested_attributes_for :job_answers, allow_destroy: true

  def status_enum
    [['pending'],['selected'],['rejected'],['on hold'],['denied']]
  end#status_enum

  rails_admin do
    edit do
      field :job do
        read_only true
      end
      field :job_applicant do
        read_only true
      end
      field :interview_date
      field :status
      field :status_reason
      field :comments_remarks
      field :email_subject
      field :email_body, :ck_editor
      field :send_email
      field :job_source do
        read_only true
      end
    end

    list do
      field :id
      field :job
      field :job_applicant do
        label 'Applicant'
        pretty_value do
          bindings[:view].link_to(
            bindings[:object].job_applicant&.email,
            bindings[:view].rails_admin.show_path('JobApplicant', bindings[:object].job_applicant.id)
          ) if bindings[:object].job_applicant.present?
        end
      end
      field :interview_date
      field :status
      field :status_reason
      field :comments_remarks
      field :send_email
      field :created_at
      field :updated_at
      field :job_source
    end
  end

  def send_info
    if (send_email and email_body_previously_changed? and persisted?)
      JobMailer.job_application_status_alert(self,email_body,email_subject).deliver_later
    end#address1_proof
  end#send_info

  def track_changes_in_table
    if Current.toc.present? && self.saved_changes.present? 
      row = JobApplication.find(self.id)
      version = PaperTrail::Version.where('item_type=? and item_id=? and whodunnit=?','JobApplication',self.id,Current.toc.id.to_s).last.object_changes rescue nil
      if version.present?
        version_data = version.gsub("\n"," ").gsub("--- ","")
        message = "Admin #{Current.toc.email} with id '#{Current.toc.id}' updated the following fields of JobApplication '#{row.id}'"+' '+version_data
        subject = "Admin  with id '#{Current.toc.id}', role #{Current.toc.role.role} updated JobApplication table"
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
