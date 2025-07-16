require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'

 
module RailsAdminJobApplicantVerifiedEdit
end

module RailsAdmin
	module Config
		module Actions
			class JobApplicantVerifiedEdit < RailsAdmin::Config::Actions::Base
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
						@user = JobApplicant.find(params[:id])
						if request.post?
							if @user.verified != true
								@user.verified_alert = params[:job_applicant][:verified_alert]
								@user.verified = params[:job_applicant][:verified]
								# if user tier verified is false or   all proofs are verified
								if !@user.verified || (@user.resume_status =="accepted" and @user.aadhar_status =="accepted")
									if @user.save
										flash[:notice] ="Updated User verified to #{@user.verified} "
									else
										flash[:alert]="Unable to save because: #{@user.errors.full_messages.join(", ")}"
										redirect_to job_applicant_verified_edit_path
									end
								else
									flash[:alert]="Please verify Aadhar and Resume"
									redirect_to job_applicant_verified_edit_path
								end
							else
								flash[:alert]="You are not authorized"
								redirect_to job_applicant_verified_edit_path
							end
						end
					end
				end
			end
		end
	end
end  