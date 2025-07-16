require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'

 
module RailsAdminPendingKycUsers
end

module RailsAdmin
	module Config
		module Actions
			class PendingKycUsers < RailsAdmin::Config::Actions::Base
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
						@selected = params[:selected] || "all"
						@show_email = Current.toc.role.show_email
						if @selected=="all"
							@users = User.where("(users.kyc_verified = false) OR pan_card_status!=? or aadhar_status!=? or company_id_card_status!=?","accepted","accepted","accepted").order(id: :desc)
							@total_users = @users.count
						elsif @selected=="pan_card"
							@users = User.select(:id,:email,:emp_status,:pan_card_status).where("pan_card_status =?","pending")
							@total_users = @users.size
						elsif @selected=="aadhar"
							@users = User.select(:id,:email,:emp_status,:aadhar_status).where("aadhar_status =?","pending")
							@total_users = @users.size
						elsif @selected=="company_id_card"
							@users = User.select(:id,:email,:emp_status,:company_id_card_status).where("company_id_card_status =?","pending")
							@total_users = @users.size
						elsif @selected=="kyc_verified"
							@users = User.select(:id,:email,:emp_status,:kyc_verified).where("pan_card_status=? and aadhar_status =? and company_id_card_status =? and kyc_verified =?","accepted","accepted","accepted",false)
							@total_users = @users.size
						end
						@users=@users.page(params[:page]).per(30) rescue nil
					end
				end
			end
		end
	end
end