require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'

 
module RailsAdminJobApplicantExpDocumentEdit
end

module RailsAdmin
	module Config
		module Actions
			class JobApplicantExpDocumentEdit < RailsAdmin::Config::Actions::Base
				register_instance_option :visible? do
					authorized?
				end

				register_instance_option :link_icon do
					'fa fa-file-image'
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
							# if current dogin is not employee OR have access to exp_document proof 
							if @user.exp_document_status != "accepted"
								if params[:job_applicant].present?
									@user.exp_document = params[:job_applicant][:exp_document]
                  if @user.exp_document.present?
										@user.exp_document_status ="pending"
										if @user.save
										else
											flash[:alert]="Unable to save because: #{@user.errors.full_messages.join(", ")}"
											redirect_to job_applicant_exp_document_edit_path
										end
									else
										flash[:alert]="please upload company id card"
										redirect_to job_applicant_exp_document_edit_path
									end
								else
									redirect_to job_applicant_exp_document_edit_path
								end
							else
								flash[:alert]="exp_document already accepted"
								redirect_to main_app.root_path
							end
						end
					end
				end
			end
		end
	end
end  