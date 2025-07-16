require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'

 
module RailsAdminPendingKycUserUpdate
end

module RailsAdmin
	module Config
		module Actions
			class PendingKycUserUpdate < RailsAdmin::Config::Actions::Base
				register_instance_option :visible? do
					authorized?
				end

				register_instance_option :link_icon do
					'fa fa-clock'
				end

				register_instance_option :member? do
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
						@user = User.find(params[:id])
						if request.post?
							@user.emp_status = params[:user][:emp_status] 
							if @user.save
								flash[:notice]="Updated Employee status to #{@user.emp_status}"
							else
								flash[:alert]="Unable to save because: #{@user.errors.full_messages.join(", ")}"
								redirect_to pending_kyc_user_update_path
							end
						end
					end
				end
			end
		end
	end
end  