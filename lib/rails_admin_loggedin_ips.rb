require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'
 
module RailsAdminLoggedinIps
end

module RailsAdmin
  module Config
    module Actions
      class LoggedinIps < RailsAdmin::Config::Actions::Base
        register_instance_option :visible? do
          authorized?
        end

        register_instance_option :link_icon do
          'fa fa-sign-in-alt'
        end

        register_instance_option :member? do
          true
        end

        register_instance_option :controller do
          Proc.new do
            @user=User.find(params[:id])
            @unique_ips= LoginHistory.where("user_id=?",params[:id]).pluck(:ip_address).uniq rescue []
          end
        end
      end
    end
  end
end  