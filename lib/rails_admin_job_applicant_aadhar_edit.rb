require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'

 
module RailsAdminJobApplicantAadharEdit
end

module RailsAdmin
	module Config
		module Actions
			class JobApplicantAadharEdit < RailsAdmin::Config::Actions::Base
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
						@user = JobApplicant.find(params[:id])
						if request.post?
							if @user.aadhar_status != "accepted"
								@user.aadhar_number = params[:job_applicant][:aadhar_number] if params[:job_applicant][:aadhar_number].present?
								if params[:job_applicant][:aadhar].present?
									@user.aadhar =params[:job_applicant][:aadhar]
									@user.aadhar_status = "pending"
								end
								if @user.save
								else
									flash[:alert]="Unable to save because: #{@user.errors.full_messages.join(", ")}"
									redirect_to job_applicant_aadhar_edit_path
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