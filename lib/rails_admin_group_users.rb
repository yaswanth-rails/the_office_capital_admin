require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'
 
module RailsAdminGroupUsers
end

module RailsAdmin
  module Config
    module Actions
      class GroupUsers < RailsAdmin::Config::Actions::Base
        register_instance_option :visible? do
          authorized?
        end

        register_instance_option :link_icon do
          'fa fa-users'
        end

        register_instance_option :collection? do
          false
        end

        register_instance_option :member? do
          true
        end
        register_instance_option :pjax? do
          false
        end
        register_instance_option :controller do
          Proc.new do
            @group = Group.find(params[:id])
            @users = User.where("group_id =?",@group.id )
            @users=@users.page(params[:page]).per(50)
          end#Proc
        end
      end
    end
  end
end  
