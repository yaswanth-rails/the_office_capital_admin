require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'
 
module ProcessMiningProcessRefund
end

module RailsAdmin
  module Config
    module Actions
      class ProcessRefund < RailsAdmin::Config::Actions::Base
        register_instance_option :visible? do
          authorized?
        end

        register_instance_option :link_icon do
          'icon-repeat'
        end

        register_instance_option :member? do
          true
        end

        register_instance_option :controller do
          Proc.new do
            if params.has_key?("otp")
              if current_toc.role.process_refund
                if current_toc.gauth_enabled?
                  valid_vals = [current_toc.backup_code.to_i]
                  valid_vals << ROTP::TOTP.new(current_toc.get_qr).at(Time.now)
                  (1..current_toc.class.ga_timedrift).each do |cc|
                    valid_vals << ROTP::TOTP.new(current_toc.get_qr).at(Time.now.ago(30*cc))
                    valid_vals << ROTP::TOTP.new(current_toc.get_qr).at(Time.now.in(30*cc))
                  end
                  if valid_vals.include?(params[:otp].to_i)
                    ################## Refund process Starts #######################
                    refunded = false
                    booking_group = nil
                    booking = Booking.find(params[:id])
                    booking.refund_remarks = params[:remarks]
                    booking.canceled_at = Time.zone.now
                    workspace = booking.workspace
                    workspace_type = workspace.workspace_type
                    if workspace_type.name.eql?"Meeting Room"
                      booking_group = nil
                    else
                      booking_group = booking.booking_group
                    end
                    booking_cancellation_percentage = params[:cancelation_percentage].to_f
                    actual_booking_cancellation_percentage = TocMaintenance.select(:booking_cancellation_percentage).first.booking_cancellation_percentage
                    cancellation_percentage = true
                    if booking_cancellation_percentage < actual_booking_cancellation_percentage
                      cancellation_percentage = false
                      flash[:alert]="Cancelation percentage should be greater than or equal to #{actual_booking_cancellation_percentage} "
                      redirect_to refund_path
                    end#if booking_cancellation_percentage < actual_booking_cancellation_percentage

                    valid_workspace = true
                    if workspace_type.name.eql?"Hot Desk" or workspace_type.name.eql?"Dedicated Desk"
                      valid_workspace = false
                      flash[:alert]="Refund process not yet done for #{workspace_type.name}"
                      redirect_to refund_path
                    end

                    if workspace_type.name.eql?"Weekly Pass"
                      if Date.today > booking.end_time.to_date
                        valid_workspace = false
                        flash[:alert]="Not able to process refund, due to Weekly pass expire."
                        redirect_to refund_path
                      end
                    end
                    if booking.status.eql?"confirmed" and booking.payment_status.eql?"paid" and cancellation_percentage and valid_workspace
                      ActiveRecord::Base.transaction do
                        fee_percentage = (booking_cancellation_percentage/100.0)
                        booking_total_amount = booking.total_amount
                        if workspace_type.name.eql?"Weekly Pass"
                          if Date.today >= booking.start_time.to_date
                            differene = (booking.start_time.to_date..Date.today).count{ |date| date.wday != 0 }
                            differene_amount = (differene * (booking_total_amount/7.0)).round(2)
                            booking_total_amount = (booking.total_amount - differene_amount).round(2)
                          end
                        end#if workspace_type.name.eql?"Weekly Pass"
                        total_refund = (booking_total_amount * (1 - fee_percentage)).round(2)

                        refund_bonus = 0
                        if booking_group.present?
                          if booking_group.bonus_applied > 0
                            proportion = booking_total_amount / booking_group.total_amount
                            refund_bonus = (booking_group.bonus_applied * proportion).round(2)
                          end
                        else
                          refund_bonus = booking.bonus_applied
                        end#if booking_group.present?

                        remaining_bonus = 0
                        refund_status = "refunded"
                        remaining_bonus = WalletService.refund!(
                          user: booking.user,
                          amount: total_refund,
                          bonus_amount: refund_bonus,
                          booking_group: booking_group,
                          booking: booking,
                          transaction_type: "#{workspace_type.name.downcase} booking cancel"
                        )

                        booking.refund_amount = total_refund
                        booking.refund_status = refund_status
                        booking.booking_cancellation_percentage = booking_cancellation_percentage
                        booking.status = "canceled"
                        booking.save
                        @message = "Refund processed successfully."

                        # Updated BookingGroup If booking is otherthan Meeting Room
                        if booking_group.present?
                          group_bookings_count = booking_group.bookings.count
                          group_cancel_bookings_count = booking_group.bookings.where("status = ? or status = ?","canceled","payment request canceled").count
                          partail_cancel = false
                          refund = booking_group.refund_amount + total_refund

                          #Checking BookingGroup have any canceled bookings
                          if group_cancel_bookings_count == group_bookings_count
                            booking_group.update!(canceled_at: Time.current,status: 'canceled',refund_amount: refund,refund_status: refund_status)
                          else
                            partail_cancel = true
                            booking_group.update!(canceled_at: Time.current,status: 'partially canceled',refund_amount: refund,refund_status: refund_status)
                          end#if group_cancel_bookings_count == group_bookings_count

                          UserMailer.booking_group_cancellation(booking_group,booking.id,partail_cancel,total_refund.to_f,refund_bonus.to_f,remaining_bonus.to_f,booking_cancellation_percentage.to_f,workspace_type).deliver_later
                        else
                          UserMailer.booking_cancellation_alert(booking,total_refund.to_f,refund_bonus.to_f,remaining_bonus.to_f,booking_cancellation_percentage,workspace_type).deliver_later
                        end#if booking_group.present?
                      end#ActiveRecord::Base.transaction do
                    else
                      @message="Booking Already Canceled"
                    end#if booking.status.eql?"confirmed" and booking.payment_status.eql?"paid"
                  else
                    @message="Invalid OTP"
                  end#if valid_vals.include?(params[:otp].to_i)
                else
                  @message="Please Enable 2FA"
                end#if current_toc.gauth_enabled?
              else
                @message="You are not authorized"
              end#if current_toc.role.role.process_refund
            else
              @message="Invalid OTP"
            end#if params.has_key?("otp")
          end
        end
      end
    end
  end
end  