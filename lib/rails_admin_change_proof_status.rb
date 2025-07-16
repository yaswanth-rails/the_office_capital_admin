require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'

 
module RailsAdminChangeProofStatus
end

module RailsAdmin
	module Config
		module Actions
			class ChangeProofStatus < RailsAdmin::Config::Actions::Base
				register_instance_option :visible? do
					authorized?
				end
				register_instance_option :show_in_menu do
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
            ##Find the user
						@user = User.find(params[:id])
            # p "action"
						if request.post?
							# if id proof to be modified
							if params[:proof]=="pan_card"
							# if  current toc is not employee or employee and have access to update id proof
								if current_toc.role.role !="employee" || (@user.pan_card_status != "accepted" && current_toc.role.role =="employee" && current_toc.role.can_update_pan_card ==true)
									if params[:user][:pan_card_status] =="rejected"
										if params[:user][:pan_card_rejected_reason].present?
											@user.pan_card_status = "rejected"
											@user.pan_card_rejected_reason = params[:user][:pan_card_rejected_reason]
											if @user.save
												flash[:notice]="Updated status to #{@user.pan_card_status}"
												redirect_to pan_card_edit_path
											else
												flash[:alert]="Unable to save because: #{@user.errors.full_messages.join(", ")}"
												redirect_to pan_card_edit_path
											end
										else
											flash[:alert]="Please enter valid reason for pan card"
											redirect_to pan_card_edit_path
										end
									else
										@user.pan_card_status = params[:user][:pan_card_status]
										if @user.save
											flash[:notice]="Updated status to #{@user.pan_card_status}"
											redirect_to pan_card_edit_path
										else
											flash[:alert]="Unable to save because: #{@user.errors.full_messages.join(", ")}"
											redirect_to pan_card_edit_path
										end
									end
								else
									flash[:alert]="You are not aunthorized"
									redirect_to pan_card_edit_path
								end
							# if address proof to be modified
							elsif params[:proof]=="aadhar"
								# if  current toc is not employee or employee and have access to update address proof
								if current_toc.role.role !="employee" || (@user.aadhar_status != "accepted" && current_toc.role.role =="employee" && current_toc.role.can_update_aadhar ==true)
									if params[:user][:aadhar_status] =="rejected"
										if params[:user][:aadhar_rejected_reason].present?
											@user.aadhar_status = "rejected"
											@user.aadhar_rejected_reason = params[:user][:aadhar_rejected_reason]
											if @user.save
												flash[:notice]="Updated status to #{@user.aadhar_status}"
												redirect_to aadhar_edit_path
											else
												flash[:alert]="Unable to save because: #{@user.errors.full_messages.join(", ")}"
												redirect_to aadhar_edit_path
											end
										else
											flash[:alert]="Please enter valid reason for aadhar"
											redirect_to aadhar_edit_path
										end
									else
										@user.aadhar_status = params[:user][:aadhar_status]
										if @user.save
											flash[:notice]="Updated status to #{@user.aadhar_status}"
												redirect_to aadhar_edit_path
										else
											flash[:alert]="Unable to save because: #{@user.errors.full_messages.join(", ")}"
											redirect_to aadhar_edit_path
										end
									end
								else
									flash[:alert]="You are not aunthorized"
									redirect_to aadhar_edit_path
								end
							# if company_id_card proof to be modified
							elsif params[:proof]=="company_id_card"
                # if  current toc is not employee or employee and have access to update company_id_card proof
								if current_toc.role.role !="employee" || (@user.company_id_card_status != "accepted" && current_toc.role.role =="employee" && current_toc.role.can_update_company_id_card ==true)
									if params[:user][:company_id_card_status] =="rejected"
										if params[:user][:company_id_card_rejected_reason].present?
											@user.company_id_card_status = "rejected"
											@user.company_id_card_rejected_reason = params[:user][:company_id_card_rejected_reason]
											if @user.save
												flash[:notice]="Updated status to #{@user.company_id_card_status}"
												redirect_to company_id_card_edit_path
											else
												flash[:alert]="Unable to save because: #{@user.errors.full_messages.join(", ")}"
												redirect_to company_id_card_edit_path
											end
										else
											flash[:alert]="Please enter valid reason for company_id_card"
											redirect_to company_id_card_edit_path
										end
									else
										if @user.company_id_card.present?
											@user.company_id_card_status = params[:user][:company_id_card_status]
											if @user.save
												flash[:notice]="Updated status to #{@user.company_id_card_status}"
												redirect_to company_id_card_edit_path
											else
												flash[:alert]="Unable to save because: #{@user.errors.full_messages.join(", ")}"
												redirect_to company_id_card_edit_path
											end
										else
											flash[:alert]="Please upload the proof"
											redirect_to company_id_card_edit_path
										end												
									end
								else
									flash[:alert]="You are not aunthorized"
									redirect_to company_id_card_edit_path
								end
							else
								flash[:alert]="You are not aunthorized"
								redirect_to sub_section_kyc_path
							end
						end
					end
				end
			end
		end
	end
end  