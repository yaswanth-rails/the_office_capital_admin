require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'


module RailsAdminUnverifiedBankAccUpdate
end

module RailsAdmin
	module Config
		module Actions
			class UnverifiedBankAccUpdate < RailsAdmin::Config::Actions::Base
				register_instance_option :visible? do
					authorized?
				end

				register_instance_option :link_icon do
					'fa fa-clock'
				end

				register_instance_option :member? do
					true
				end
				register_instance_option :show_in_menu? do
					false
				end

				register_instance_option :pjax? do
					false
				end
				register_instance_option :http_methods do
					[:get,:post]
				end

				register_instance_option :controller do
					Proc.new do
						@bank_account = BankAccount.find(params[:id])
						if request.post?
							@bank_account.emp_status = params[:bank_account][:emp_status]
							if @bank_account.save
								flash[:notice]="Updated Employee status to #{@bank_account.emp_status}"
							else
								flash[:alert]="Unable to save because: #{@bank_account.errors.full_messages.join(", ")}"
								redirect_to unverified_bank_acc_update_path
							end
						end
					end
				end
			end
		end
	end
end 