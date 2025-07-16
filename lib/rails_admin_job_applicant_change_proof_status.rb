require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'

 
module RailsAdminJobApplicantChangeProofStatus
end

module RailsAdmin
	module Config
		module Actions
			class JobApplicantChangeProofStatus < RailsAdmin::Config::Actions::Base
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
						@user = JobApplicant.find(params[:id])
            # p "action"
						if request.post?
							if params[:proof]=="aadhar"
								@user.aadhar_status_alert = params[:job_applicant][:aadhar_status_alert]
								if params[:job_applicant][:aadhar_status] =="rejected"
									if params[:job_applicant][:aadhar_rejected_reason].present?
										@user.aadhar_status = "rejected"
										@user.aadhar_rejected_reason = params[:job_applicant][:aadhar_rejected_reason]
										if @user.save
											flash[:notice]="Updated status to #{@user.aadhar_status}"
											redirect_to job_applicant_aadhar_edit_path
										else
											flash[:alert]="Unable to save because: #{@user.errors.full_messages.join(", ")}"
											redirect_to job_applicant_aadhar_edit_path
										end
									else
										flash[:alert]="Please enter valid reason for aadhar"
										redirect_to job_applicant_aadhar_edit_path
									end
								else
									@user.aadhar_status = params[:job_applicant][:aadhar_status]
									if @user.save
										flash[:notice]="Updated status to #{@user.aadhar_status}"
											redirect_to job_applicant_aadhar_edit_path
									else
										flash[:alert]="Unable to save because: #{@user.errors.full_messages.join(", ")}"
										redirect_to job_applicant_aadhar_edit_path
									end
								end
							# if resume status
							elsif params[:proof]=="resume"
								@user.resume_status_alert = params[:job_applicant][:resume_status_alert]
								if params[:job_applicant][:resume_status] =="rejected"
									if params[:job_applicant][:resume_rejected_reason].present?
										@user.resume_status = "rejected"
										@user.resume_rejected_reason = params[:job_applicant][:resume_rejected_reason]
										if @user.save
											flash[:notice]="Updated status to #{@user.resume_status}"
											redirect_to job_applicant_resume_edit_path
										else
											flash[:alert]="Unable to save because: #{@user.errors.full_messages.join(", ")}"
											redirect_to job_applicant_resume_edit_path
										end
									else
										flash[:alert]="Please enter valid reason for resume"
										redirect_to job_applicant_resume_edit_path
									end
								else
									if @user.resume.present?
										@user.resume_status = params[:job_applicant][:resume_status]
										if @user.save
											flash[:notice]="Updated status to #{@user.resume_status}"
											redirect_to job_applicant_resume_edit_path
										else
											flash[:alert]="Unable to save because: #{@user.errors.full_messages.join(", ")}"
											redirect_to job_applicant_resume_edit_path
										end
									else
										flash[:alert]="Please upload resume."
										redirect_to job_applicant_resume_edit_path
									end												
								end
							elsif params[:proof]=="exp_document"
								@user.exp_document_status_alert = params[:job_applicant][:exp_document_status_alert]
								if params[:job_applicant][:exp_document_status] =="rejected"
									if params[:job_applicant][:exp_document_rejected_reason].present?
										@user.exp_document_status = "rejected"
										@user.exp_document_rejected_reason = params[:job_applicant][:exp_document_rejected_reason]
										if @user.save
											flash[:notice]="Updated status to #{@user.exp_document_status}"
											redirect_to job_applicant_exp_document_edit_path
										else
											flash[:alert]="Unable to save because: #{@user.errors.full_messages.join(", ")}"
											redirect_to job_applicant_exp_document_edit_path
										end
									else
										flash[:alert]="Please enter valid reason for exp_document"
										redirect_to job_applicant_exp_document_edit_path
									end
								else
									if @user.exp_document.present?
										@user.exp_document_status = params[:job_applicant][:exp_document_status]
										if @user.save
											flash[:notice]="Updated status to #{@user.exp_document_status}"
											redirect_to job_applicant_exp_document_edit_path
										else
											flash[:alert]="Unable to save because: #{@user.errors.full_messages.join(", ")}"
											redirect_to job_applicant_exp_document_edit_path
										end
									else
										flash[:alert]="Please upload exp_document."
										redirect_to job_applicant_exp_document_edit_path
									end												
								end
							else
								flash[:alert]="You are not aunthorized"
								redirect_to job_applicant_kyc_path
							end
						end
					end
				end
			end
		end
	end
end  