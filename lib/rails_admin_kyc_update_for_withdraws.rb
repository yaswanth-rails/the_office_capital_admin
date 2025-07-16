require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'
 
module RailsAdminKycUpdateForWithdraws
end

module RailsAdmin
  module Config
    module Actions
      class KycUpdateForWithdraws < RailsAdmin::Config::Actions::Base
        register_instance_option :visible? do
          authorized?
        end

        register_instance_option :link_icon do
          'fa fa-file'
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
            @withdraws=Withdraw.where("status=?","pending")
            if @withdraws.present?
              @withdraws.each do |withdraw|
                user=withdraw.user
                if user.present?
                  verified_bank=BankAccount.where("verify=? and id=?",true,@withdraw.bank_account_id).first
                  if verified_banks.present?
                    withdraw.bank_account_verified=true
                  end#if verified_banks.present?
                  withdraw.save!(validate:false)
                end#if user.present?
              end#@withdraws.each do |withdraw|
            end#if @withdraws.present?
          end#Proc
        end
      end
    end
  end
end  
