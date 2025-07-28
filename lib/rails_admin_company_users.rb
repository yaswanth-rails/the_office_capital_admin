require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'
 
module RailsAdminCompanyUsers
end

module RailsAdmin
  module Config
    module Actions
      class CompanyUsers < RailsAdmin::Config::Actions::Base
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
            @company = Company.find(params[:id])
            group_ids = @company.groups.select(:id)
            @users = User.where(group_id: group_ids )
            @users=@users.page(params[:page]).per(50)
            @external_users = ExternalGuest.where(group_id: group_ids )
            @external_users=@external_users.page(params[:page]).per(50)
          end#Proc
        end
      end
    end
  end
end  
