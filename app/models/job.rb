class Job < ApplicationRecord
  include Current
  attr_accessor :current_toc  
  has_paper_trail on: [:update, :destroy], ignore: [:track_changes,:updated_at,:job_description], if: Proc.new { Current.toc }
  attr_accessor :executed
  after_update :track_changes_in_table, unless: :executed

	has_permalink :title, :unique => true
	has_many :job_applications
  has_many :job_question_assignments, inverse_of: :job#, dependent: :destroy
  has_many :job_questions, through: :job_question_assignments
  accepts_nested_attributes_for :job_question_assignments, allow_destroy: true

	# Ensure any input from form is properly cast to a Hash
  def qualification=(value)
    super(value.is_a?(ActionController::Parameters) ? value.to_unsafe_h : value)
  end

	def gender_enum
		[['both'],['male'],['female']]
	end#interview_type_enum

	def interview_type_enum
		[['Walk-In'],['Campus-Drive'],['in office'],['online']]
	end#interview_type_enum

	def status_enum
		[['live'],['hide']]
	end#status_enum

	def priority_number_enum
		[[1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20]]
	end#priority_number_enum

	def start_date_suffix_enum
		[['st'],['nd'],['rd'],['th']]
	end#start_date_suffix_enum

	def end_date_suffix_enum
		[['st'],['nd'],['rd'],['th']]
	end#end_date_suffix_enum

	def percentage_enum
		[['Above 50%'],['Above 60%'],['Above 70%'],['Above 80%'],['Above 90%']]
	end#percentage_enum

  rails_admin do
    edit do
      field :title
      field :permalink
      field :role
      field :gender
      field :status
      field :min_exp
      field :max_exp
      field :date_of_joining
      field :salary
      field :additional_benefits
      field :interview_process
      field :interview_type
      field :interview_start_date
      field :start_date_suffix
      field :interview_end_date
      field :end_date_suffix
      field :interview_timing
      field :work_location
      field :skills_required
      field :percentage
      field :passed_out_from
      field :passed_out_to
      field :priority_number
      field :qualification, :serialized do
        label 'Qualification'
        partial 'qualification_field'
      end
      field :job_description, :ck_editor
      # field :job_question_assignments do
      #   label "Assigned Questions"
      #   nested_form({})
      # end
    end
    # This makes sure the nested qualification hash is saved
    configure :qualification do
      def parse_input(params)
        if params[:qualification].is_a?(Hash) || params[:qualification].is_a?(ActionController::Parameters)
          params[:qualification] = params[:qualification].to_unsafe_h if params[:qualification].is_a?(ActionController::Parameters)
          params[:qualification]
        else
          {}
        end
      end
    end
    list do
      field :id
      field :title
      field :permalink
      field :role
      field :gender
      field :status
      field :created_at
      field :updated_at
      field :min_exp
      field :max_exp
      field :date_of_joining
      field :salary
      field :additional_benefits
      field :interview_process
      field :interview_type
      field :interview_start_date
      field :start_date_suffix
      field :interview_end_date
      field :end_date_suffix
      field :interview_timing
      field :work_location
      field :skills_required
      field :percentage
      field :passed_out_from
      field :passed_out_to
      field :priority_number
      field :qualification
      field :job_question_assignments
      field :job_description
    end
  end

	def format_qualification(hash)
	  parts = []

	  if hash.dig("degree_pg", "degree_pg") == "1"
	    parts << "degree or pg"
	  end

	  if hash["Btech"]&.any?
	    if hash["Btech"]["any"] == "1"
	      parts << "Btech any"
	    else
	      branches = hash["Btech"].select { |_, v| v == "1" }.keys
	      parts << "Btech #{branches.join(', ')}" if branches.any?
	    end
	  end

	  if hash["Mtech"]&.any?
	    if hash["Mtech"]["any"] == "1"
	      parts << "Mtech any"
	    else
	      branches = hash["Mtech"].select { |_, v| v == "1" }.keys
	      parts << "Mtech #{branches.join(', ')}" if branches.any?
	    end
	  end

	  parts << "MCA" if hash.dig("mca", "mca") == "1"
	  parts << "Msc. computers" if hash.dig("msc", "computers") == "1"

	  parts.join(', ')
	end

  def track_changes_in_table
    if Current.toc.present? && self.saved_changes.present? 
      row = Job.find(self.id)
      version = PaperTrail::Version.where('item_type=? and item_id=? and whodunnit=?','Job',self.id,Current.toc.id.to_s).last.object_changes rescue nil
      if version.present?
        version_data = version.gsub("\n"," ").gsub("--- ","")
        message = "Admin #{Current.toc.email} with id '#{Current.toc.id}' updated the following fields of Job '#{row.id}'"+' '+version_data
        subject = "Admin  with id '#{Current.toc.id}', role #{Current.toc.role.role} updated JOB table"
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
