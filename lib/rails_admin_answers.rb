require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'
 
module RailsAdminAnswers
end

module RailsAdmin
  module Config
    module Actions
      class Answers < RailsAdmin::Config::Actions::Base
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
            @job_answers = @job_application.job_answers
          end
        end
      end
    end
  end
end  