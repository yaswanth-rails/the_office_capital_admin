require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'
 
module RailsAdminSubSectionKyc
end

module RailsAdmin
	module Config
		module Actions
			class SubSectionKyc < RailsAdmin::Config::Actions::Base
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
						@user = User.find(params[:id])
						if params[:kyc_reminder].eql?"true"
							@kyc_reminder=params[:kyc_reminder]
							@proof = params[:proof]
							subject=""
							if @proof.eql?"Pan Card" and (!@user.pan_card_status.eql?"pending" and !@user.pan_card_status.eql?"accepted")
								@kyc_reminder = true
								if @user.pan_card_status.eql?"not uploaded"
									subject = "#{@user.firstname || @user.email} - Action Required: Submit your pan card."
								elsif @user.pan_card_status.eql?"rejected"
									subject = "#{@user.firstname || @user.email} - Action Required: Submit your pan card."
								end
							elsif @proof.eql?"Aadhar" and (!@user.aadhar_status.eql?"pending" and !@user.aadhar_status.eql?"accepted")
								@kyc_reminder = true
								if @user.aadhar_status.eql?"not uploaded"
									subject = "#{@user.firstname || @user.email} - Action Required: Submit your aadhar."
								elsif @user.aadhar_status.eql?"rejected"
									subject = "#{@user.firstname || @user.email} - Action Required: Submit your aadhar."
								end
							elsif @proof.eql?"Company ID Card" and (!@user.company_id_card_status.eql?"pending" and !@user.company_id_card_status.eql?"accepted")
								@kyc_reminder = true
								if @user.company_id_card_status.eql?"not uploaded"
									subject = "#{@user.firstname || @user.email} - Action Required: Submit your company id card."
								elsif @user.company_id_card_status.eql?"rejected"
									subject = "#{@user.firstname || @user.email} - Action Required: Re-Submit your company id card."
								end
							else
								@kyc_reminder = false
							end
							if @kyc_reminder
								UserMailer.send_kyc_reminder(@user,@proof,subject).deliver_later
							end
						end
					end
				end
			end
		end
	end
end  