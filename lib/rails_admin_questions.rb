require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'
 
module RailsAdminQuestions
end

module RailsAdmin
  module Config
    module Actions
      class Questions < RailsAdmin::Config::Actions::Base
        register_instance_option :visible? do
          authorized?
        end

        register_instance_option :link_icon do
          'fa fa-list'
        end

        register_instance_option :member? do
          true
        end

        register_instance_option :controller do
          Proc.new do
            @job = Job.find(params[:id])
            @job_questions = @job.job_question_assignments.includes(:job_question).order(:position).map(&:job_question)
          end
        end
      end
    end
  end
end  