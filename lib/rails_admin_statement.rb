require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'
 
module RailsAdminStatement
end

module RailsAdmin
  module Config
    module Actions
      class Statement < RailsAdmin::Config::Actions::Base
        register_instance_option :visible? do
          authorized?
        end

        register_instance_option :only do
          [Company, Wallet, User]
        end
        register_instance_option :link_icon do
          'fa fa-list'
        end

        register_instance_option :member? do
          true
        end

        register_instance_option :controller do
          Proc.new do
            model_name = @abstract_model.model_name
            if model_name.eql?"Wallet"
              @model_name = "wallet"
              @wallet = Wallet.find(params[:id])
              @company = @wallet.company
              @id = @wallet.id
            elsif model_name.eql?"Company"
              @model_name = "company"
              @company = Company.find(params[:id])
              @wallet = @company.wallets.first
              @id = @company.id
            elsif model_name.eql?"User"
              @model_name = "user"
              @user = User.find(params[:id])
              @company = @user.company
              @wallet = @company.wallets.first
              @id = @user.id
            end

            if params.has_key?(:account_type) 
              @account_type = params[:account_type]
            else
              @account_type="inr account"
            end#if params.has_key?(:account_type)
            @error_message = nil
            
            if !@error_message.present?
              @statements=WalletHistory.unscoped.where("account_type = ? and wallet_id = ?",@account_type, @wallet.id).order("statement_date desc") rescue nil
              @statements=@statements.page(params[:page]).per(20) rescue nil
            end#if @error_message.present?
          end
        end
      end
    end
  end
end  