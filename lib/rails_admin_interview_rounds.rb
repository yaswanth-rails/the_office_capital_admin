require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'
 
module RailsAdminInterviewRounds
end

module RailsAdmin
  module Config
    module Actions
      class InterviewRounds < RailsAdmin::Config::Actions::Base
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
            @job_application = JobApplication.find(params[:id])
            @interview_rounds = @job_application.interview_round_statuses.page(params[:page]).per(20) rescue nil
          end
        end
      end
    end
  end
end  