class InterviewRoundStatus < ApplicationRecord
  include Current
  attr_accessor :current_toc  
  has_paper_trail on: [:update, :destroy], ignore: [:track_changes,:updated_at,:job_description], if: Proc.new { Current.toc }
  attr_accessor :executed
  after_update :track_changes_in_table, unless: :executed
  after_create :send_schedule
  after_update :send_reschedule

	belongs_to :interview_round
	belongs_to :job_applicant
	belongs_to :job_application

	def test_status_enum
		[['pending'],['passed'],['failed'],['cleared'],['not cleared']]
	end#test_status_enum

  rails_admin do
    edit do
      field :interview_round
      field :job_applicant_id do
        def render
          bindings[:view].render :partial => 'job_applicants', :locals => {:field => self, :form => bindings[:form]}
        end
      end
      field :job_application_id do
        def render
          bindings[:view].render :partial => 'job_applications', :locals => {:field => self, :form => bindings[:form]}
        end
      end
      field :interview_round_date
      field :timing
      field :schedule_email_subject
      field :schedule_email_body, :ck_editor
      field :reschedule_date
      field :reschedule_email_subject
      field :reschedule_email_body, :ck_editor
      field :send_email
      field :marks
      field :test_status
      field :reject_reason
    end

    list do
      field :id
      field :interview_round
      field :job_applicant do
        label 'Applicant'
        pretty_value do
          bindings[:view].link_to(
            bindings[:object].job_applicant&.email,
            bindings[:view].rails_admin.show_path('JobApplicant', bindings[:object].job_applicant.id)
          ) if bindings[:object].job_applicant.present?
        end
      end
      field :job_application do
        label 'Job Applicantion'
        pretty_value do
          bindings[:view].link_to(
            bindings[:object].job_application&.job&.role,
            bindings[:view].rails_admin.show_path('JobApplication', bindings[:object].job_application.id)
          ) if bindings[:object].job_application.present?
        end
      end
      field :job_application
      field :interview_round_date
      field :timing
      field :reschedule_date
      field :marks
      field :test_status
      field :reject_reason
      field :created_at
      field :updated_at
    end
  end

  def send_schedule
    if self.send_email
      JobMailer.send_interview_round_schedule_details(self,self.schedule_email_body,self.schedule_email_subject).deliver_later
    end
  end#send_schedule

  def send_reschedule
    if (send_email and reschedule_email_body_previously_changed? and persisted?)
      JobMailer.send_interview_round_schedule_details(self,reschedule_email_body,reschedule_email_subject).deliver_later
    end
    if (send_email and schedule_email_body_previously_changed? and persisted?)
      JobMailer.send_interview_round_schedule_details(self,schedule_email_body,schedule_email_subject).deliver_later
    end
  end#send_schedule

  def track_changes_in_table
    if Current.toc.present? && self.saved_changes.present? 
      row = InterviewRoundStatus.find(self.id)
      version = PaperTrail::Version.where('item_type=? and item_id=? and whodunnit=?','InterviewRoundStatus',self.id,Current.toc.id.to_s).last.object_changes rescue nil
      if version.present?
        version_data = version.gsub("\n"," ").gsub("--- ","")
        message = "Admin #{Current.toc.email} with id '#{Current.toc.id}' updated the following fields of InterviewRoundStatus '#{row.id}'"+' '+version_data
        subject = "Admin  with id '#{Current.toc.id}', role #{Current.toc.role.role} updated InterviewRoundStatus table"
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
