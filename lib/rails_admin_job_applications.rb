require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'
 
module RailsAdminJobApplications
end

module RailsAdmin
  module Config
    module Actions
      class JobApplications < RailsAdmin::Config::Actions::Base
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
            @job_applications = @job.job_applications.order("created_at desc").page(params[:page]).per(50) rescue nil
          end
        end
      end
    end
  end
end  