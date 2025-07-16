require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'

 
module RailsAdminPanCardEdit
end

module RailsAdmin
	module Config
		module Actions
			class PanCardEdit < RailsAdmin::Config::Actions::Base
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
							# if  current dogin is not employee or employee and have access to update  
							if current_toc.role.role !="employee" || (@user.pan_card_status != "accepted" && current_toc.role.role =="employee" && current_toc.role.can_update_pan_card ==true)
								@user.dob = params[:user][:dob] if params[:user][:dob].present?
								@user.pan_number = params[:user][:pan_number] if params[:user][:pan_number].present?
								@user.pan_card = params[:user][:pan_card] if params[:user][:pan_card].present?
								@user.admin_verified_pan_card = params[:user][:admin_verified_pan_card] if params[:user][:admin_verified_pan_card].present?
								# checking if pan card type and pan card number is present
								if @user.pan_number.present?
									# if date of birth is not nil
									if !@user.dob.nil?
										if @user.pan_card.present? || @user.admin_verified_pan_card.present?
												@user.pan_card_status = "pending"
												if @user.save
												else
													flash[:alert]="Unable to save because: #{@user.errors.full_messages.join(", ")}"
													redirect_to pan_card_edit_path
												end
										# Both pan card front and admin verified pan card front is not present 
										else
											flash[:alert]="Please upload either pan card front or admin verfied pan card front"
											redirect_to pan_card_edit_path
										end
									else
										flash[:alert]="Please enter date of birth correctly"
										redirect_to pan_card_edit_path
									end
								# if pan card type or pan card number is not present
								else
									flash[:alert]="Please enter the pan card number"
									redirect_to pan_card_edit_path
								end
							else
								redirect_to main_app.root_path
							end
						end
					end
				end
			end
		end
	end
end  