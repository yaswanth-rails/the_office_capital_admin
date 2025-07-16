class JobQuestionAssignment < ApplicationRecord
  include Current
  attr_accessor :current_toc
  has_paper_trail on: [:update, :destroy], ignore: [:track_changes,:updated_at], if: Proc.new { Current.toc }
  attr_accessor :executed
  after_update :track_changes_in_table, unless: :executed
  before_destroy :send_deletion_email
  belongs_to :job
  belongs_to :job_question

  validates :job_question_id, uniqueness: { scope: :job_id, message: "already added to this job" }

  rails_admin do
    edit do
      field :job do
        label "Select Job"
      end
      field :job_question do
        label "Select Question"
      end
      field :position
    end

    list do
      field :id
      field :job
      field :job_question
      field :position
      field :created_at
      field :updated_at
    end
  end

  def send_deletion_email
    row = JobQuestionAssignment.find(self.id)
    message = "Admin #{Current.toc.email} with id '#{Current.toc.id}' Deleted the JobQuestionAssignment '#{row.id}.'"+' '+ row.inspect
    subject = "Admin  with id '#{Current.toc.id}', role #{Current.toc.role.role} Deleted JobQuestionAssignment row"
    UserMailer.track_changes(message,subject).deliver_later
  end
  def track_changes_in_table
    if Current.toc.present? && self.saved_changes.present? 
      row = JobQuestionAssignment.find(self.id)
      version = PaperTrail::Version.where('item_type=? and item_id=? and whodunnit=?','JobQuestionAssignment',self.id,Current.toc.id.to_s).last.object_changes rescue nil
      if version.present?
        version_data = version.gsub("\n"," ").gsub("--- ","")
        message = "Admin #{Current.toc.email} with id '#{Current.toc.id}' updated the following fields of JobQuestionAssignment '#{row.id}'"+' '+version_data
        subject = "Admin  with id '#{Current.toc.id}', role #{Current.toc.role.role} updated JobQuestionAssignment table"
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
