class JobAnswer < ApplicationRecord
  include Current
  attr_accessor :current_toc
  has_paper_trail on: [:update, :destroy], ignore: [:track_changes,:updated_at,:job_description], if: Proc.new { Current.toc }
  belongs_to :job_application
  belongs_to :job_question
  validates_format_of :string_response, :with=> /\A[a-zA-Z0-9., ]*\z/, message: "Invalid answer"
end
