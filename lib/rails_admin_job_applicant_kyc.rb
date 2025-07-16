require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'
 
module RailsAdminJobApplicantKyc
end

module RailsAdmin
	module Config
		module Actions
			class JobApplicantKyc < RailsAdmin::Config::Actions::Base
				register_instance_option :visible? do
					authorized?
				end

				register_instance_option :link_icon do
					'fa fa-user-plus'
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

				register_instance_option :controller do
					Proc.new do  
						@user = JobApplicant.find(params[:id])
						if params[:kyc_reminder].eql?"true"
							@kyc_reminder=params[:kyc_reminder]
							@proof = params[:proof]
							subject=""
							if @proof.eql?"Aadhar" and (!@user.aadhar_status.eql?"pending" and !@user.aadhar_status.eql?"accepted")
								@kyc_reminder = true
								if @user.aadhar_status.eql?"not uploaded"
									subject = "#{@user.full_name} - Action Required: Submit your aadhar."
								elsif @user.aadhar_status.eql?"rejected"
									subject = "#{@user.full_name} - Action Required: Submit your aadhar."
								end
							elsif @proof.eql?"Resume" and (!@user.resume_status.eql?"pending" and !@user.resume_status.eql?"accepted")
								@kyc_reminder = true
								if @user.resume_status.eql?"not uploaded"
									subject = "#{@user.full_name} - Action Required: Upload your resume."
								elsif @user.resume_status.eql?"rejected"
									subject = "#{@user.full_name} - Action Required: Re Upload your resume."
								end
							# elsif @proof.eql?"ExpDocument" and (!@user.exp_document_status.eql?"pending" and !@user.exp_document_status.eql?"accepted")
							# 	@kyc_reminder = true
							# 	if @user.exp_document_status.eql?"not uploaded"
							# 		subject = "#{@user.full_name} - Action Required: Upload your Experience Document."
							# 	elsif @user.exp_document_status.eql?"rejected"
							# 		subject = "#{@user.full_name} - Action Required: Re Upload your Experience Document."
							# 	end
							else
								@kyc_reminder = false
							end
							if @kyc_reminder
								JobMailer.send_job_applicant_kyc_reminder(@user,@proof,subject).deliver_later
							end
						end
					end
				end
			end
		end
	end
end  