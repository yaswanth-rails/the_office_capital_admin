require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'

 
module RailsAdminKycVerifiedEdit
end

module RailsAdmin
	module Config
		module Actions
			class KycVerifiedEdit < RailsAdmin::Config::Actions::Base
				register_instance_option :visible? do
					authorized?
				end

				register_instance_option :link_icon do
					'fa fa-id-card'
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
				register_instance_option :http_methods do
					[:get,:post]
				end

				register_instance_option :controller do
					Proc.new do
						@user = User.find(params[:id])
						if request.post?
							# if toc is not a employee OR tier verified not true and toc is employee and have access to tier verified update 
							if current_toc.role.role !="employee" || (@user.kyc_verified != true && current_toc.role.role =="employee" && current_toc.role.can_update_kyc_verified)
								@user.kyc_verified = params[:user][:kyc_verified]
								# if user tier verified is false or   all proofs are verified
								if !@user.kyc_verified || (@user.pan_card_status =="accepted"  or @user.aadhar_status =="accepted")
									if @user.save
										flash[:notice] ="Updated User KYC verified to #{@user.kyc_verified} "
									else
										flash[:alert]="Unable to save because: #{@user.errors.full_messages.join(", ")}"
										redirect_to kyc_verified_edit_path
									end
								else
									flash[:alert]="Please verify Kyc proofs(either Aadhar or Pan card)"
									redirect_to kyc_verified_edit_path
								end
							else
								flash[:alert]="You are not authorized"
								redirect_to kyc_verified_edit_path
							end
						end
					end
				end
			end
		end
	end
end  