require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'
 
module RailsAdminBlockUser
end
module RailsAdmin
  module Config
    module Actions
      class BlockUser < RailsAdmin::Config::Actions::Base
        register_instance_option :visible? do
          authorized?
        end

        register_instance_option :link_icon do
          'fa fa-ban'
        end

        register_instance_option :member? do
          true
        end

        register_instance_option :controller do
          Proc.new do
            @user = User.find(params[:id])
            if @user.selfie.present?
              @selfie = @user.selfie_url
            end#if @user.selfie_file_name.present?
          end#Proc.new do
        end#register_instance_option :controller do
      end#class BlockUser
    end#module Actions
  end#module Config
end#module RailsAdmin  