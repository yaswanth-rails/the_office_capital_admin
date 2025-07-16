require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'


module RailsAdminUnverifiedBankAccounts
end

module RailsAdmin
	module Config
		module Actions
			class UnverifiedBankAccounts < RailsAdmin::Config::Actions::Base
				register_instance_option :visible? do
					authorized?
				end

				register_instance_option :link_icon do
					'fa fa-clock'
				end

				register_instance_option :collection? do
					true
				end

				register_instance_option :pjax? do
					false
				end
				register_instance_option :http_methods do
					[:get,:post]
				end

				register_instance_option :controller do
					Proc.new do
						# bank accounts not verified and bank account proof is present 
						@bank_accounts = BankAccount.where("verify=? and (emp_status=? or emp_status=?)",false,"pending","in-review")
						@bank_accounts=@bank_accounts.page(params[:page]).per(30)
					end
				end
			end
		end
	end
end 