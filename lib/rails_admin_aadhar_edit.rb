require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'

 
module RailsAdminAadharEdit
end

module RailsAdmin
	module Config
		module Actions
			class AadharEdit < RailsAdmin::Config::Actions::Base
				register_instance_option :visible? do
					authorized?
				end

				register_instance_option :link_icon do
					'fa fa-address-card'
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
					[:get, :post]
				end

				register_instance_option :controller do
					Proc.new do
						@user = User.find(params[:id])
						if request.post?
							# if  current toc is not employee or employee and have access to update  
							if current_toc.role.role !="employee" || (@user.aadhar_status != "accepted" && current_toc.role.role =="employee" && current_toc.role.can_update_aadhar)

								@user.aadhar_number = params[:user][:aadhar_number] if params[:user][:aadhar_number].present?
								@user.country = params[:user][:country] if params[:user][:country].present?
								@user.state = params[:user][:state] if params[:user][:state].present?
								# @user.aadhar_expiry_date = params[:user][:aadhar_expiry_date] if params[:user][:aadhar_expiry_date].present?
								@user.aadhar_front =params[:user][:aadhar_front] if params[:user][:aadhar_front].present?
								@user.aadhar_back =params[:user][:aadhar_back] if params[:user][:aadhar_back].present?
								@user.admin_verified_aadhar_front =params[:user][:admin_verified_aadhar_front] if params[:user][:admin_verified_aadhar_front].present?
								@user.admin_verified_aadhar_back =params[:user][:admin_verified_aadhar_back] if params[:user][:admin_verified_aadhar_back].present?
                if @user.aadhar_number.present?
                  # Either aadhar front or admin verified aadhar front is present 
									if @user.aadhar_front.present? || @user.admin_verified_aadhar_front.present? 
											@user.aadhar_status = "pending"
											if @user.save
											else
												flash[:alert]="Unable to save because: #{@user.errors.full_messages.join(", ")}"
												redirect_to aadhar_edit_path
											end
										# end
									# Both aadhar front and admin verified aadhar front is not present 
									else
										flash[:alert]="Please upload either aadhar front or admin verfied aadhar front"
										redirect_to aadhar_edit_path
									end
								# if aadhar type or aadhar number is not present
                else
                  flash[:alert]="Please enter the aadhar number"
                  redirect_to aadhar_edit_path
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