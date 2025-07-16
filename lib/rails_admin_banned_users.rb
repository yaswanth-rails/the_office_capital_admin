require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'
 
module RailsAdminBannedUsers
end

module RailsAdmin
  module Config
    module Actions
      class BannedUsers < RailsAdmin::Config::Actions::Base
        register_instance_option :visible? do
          authorized?
        end

        register_instance_option :link_icon do
          'fa fa-list-alt'
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
            @banned_users=User.where("banned=? or unsubscribe=? ",true,true).order(id: :desc)
            @banned_users=@banned_users.page(params[:page]).per(200)
          end#Proc
        end
      end
    end
  end
end  
