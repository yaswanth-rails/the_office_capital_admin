require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'
 
module RailsAdminOnlineUsers
end

module RailsAdmin
  module Config
    module Actions
      class OnlineUsers < RailsAdmin::Config::Actions::Base
        register_instance_option :visible? do
          authorized?
        end

        register_instance_option :link_icon do
          'fa fa-users'
        end

        register_instance_option :collection? do
          true
        end

        register_instance_option :member? do
          false
        end
        register_instance_option :pjax? do
          false
        end
        register_instance_option :controller do
          Proc.new do
            @online_users=User.where("auth_tokens IS NOT NULL and last_response_at is not null and last_response_at > ? ",15.minutes.ago).order(last_response_at: :desc)
            @online_users=@online_users.page(params[:page]).per(200)
          end#Proc
        end
      end
    end
  end
end  
