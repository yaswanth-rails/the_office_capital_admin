require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'

 
module RailsAdminCompanyIdCardEdit
end

module RailsAdmin
	module Config
		module Actions
			class CompanyIdCardEdit < RailsAdmin::Config::Actions::Base
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
					@user = User.find(params[:id])
						if request.post?
							# if current dogin is not employee OR have access to company_id_card proof 
							if current_toc.role.role !="employee" || (@user.company_id_card_status != "accepted" && current_toc.role.role =="employee" && current_toc.role.can_update_company_id_card)
								if params[:user].present?
									@user.company_id_card = params[:user][:company_id_card]
                  if @user.company_id_card.present?
										@user.company_id_card_status ="pending"
										if @user.save
										else
											flash[:alert]="Unable to save because: #{@user.errors.full_messages.join(", ")}"
											redirect_to company_id_card_edit_path
										end
									else
										flash[:alert]="please upload company id card"
										redirect_to company_id_card_edit_path
									end
								else
									redirect_to company_id_card_edit_path
								end
							else
								flash[:alert]="You are not authorized"
								redirect_to main_app.root_path
							end
						end
					end
				end
			end
		end
	end
end  