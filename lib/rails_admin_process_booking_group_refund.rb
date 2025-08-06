require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'
 
module ProcessMiningProcessBookingGroupRefund
end

module RailsAdmin
  module Config
    module Actions
      class ProcessBookingGroupRefund < RailsAdmin::Config::Actions::Base
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
                    booking_group = BookingGroup.find(params[:id])
                    first_booking = booking_group.bookings.first
                    workspace_type = first_booking.workspace.workspace_type

                    booking_group.refund_remarks = params[:remarks]
                    booking_group.canceled_at = Time.zone.now
                    booking_cancellation_percentage = params[:cancelation_percentage].to_f
                    actual_booking_cancellation_percentage = TocMaintenance.select(:booking_cancellation_percentage).first.booking_cancellation_percentage
                    cancellation_percentage = true

                    if booking_cancellation_percentage < actual_booking_cancellation_percentage
                      cancellation_percentage = false
                      flash[:alert]="Cancelation percentage should be greater than or equal to #{actual_booking_cancellation_percentage} "
                      redirect_to booking_group_refund_path
                    end#if booking_cancellation_percentage < actual_booking_cancellation_percentage
                    valid_workspace = true
                    if workspace_type.name.eql?"Hot Desk" or workspace_type.name.eql?"Dedicated Desk"
                      valid_workspace = false
                      flash[:alert]="Refund process not yet done for #{workspace_type.name}"
                      redirect_to refund_path
                    end
                    if (booking_group.status.eql?"confirmed" or booking_group.status.eql?"visited" or booking_group.status.eql?"partially canceled") and booking_group.payment_status.eql?"paid" and cancellation_percentage and valid_workspace
                      active_bookings = booking_group.bookings.where("(status = ? or status =?) and payment_status = ?","confirmed","cancel requested","paid")
                      ActiveRecord::Base.transaction do
                        fee_percentage = (booking_cancellation_percentage/100.0)

                        active_bookings_total_amount = active_bookings.sum(:total_amount)
                        if @workspace_type.eql?"Weekly Pass"
                          if Date.today > first_booking.start_time.to_date
                            differene = (first_booking.start_time.to_date..Date.today).count{ |date| date.wday != 0 }
                            @differene_amount = (differene * (first_booking.total_amount/7.0)).round(2)
                            active_bookings_total_amount = (active_bookings_total_amount - (@differene_amount * active_bookings.count)).round(2)
                          end
                        end#if @workspace_type.eql?"Weekly Pass"

                        total_refund = (active_bookings_total_amount * (1 - fee_percentage)).round(2)
                        refund_bonus = 0
                        if booking_group.bonus_applied > 0
                          proportion = active_bookings_total_amount / booking_group.total_amount
                          refund_bonus = (booking_group.bonus_applied * proportion).round(2)
                        end

                        remaining_bonus = 0
                        refund_status = "refunded"
                        remaining_bonus = WalletService.refund!(
                          user: booking_group.created_by,
                          amount: total_refund,
                          bonus_amount: refund_bonus,
                          booking_group: booking_group,
                          booking: nil,
                          transaction_type: "#{workspace_type.name.downcase} booking cancel"
                        )

                        refund_amount_per_booking = total_refund.to_f/active_bookings.count
                        active_bookings.each { |b| b.update!(status: 'canceled', canceled_at: Time.current,refund_amount: refund_amount_per_booking,refund_status: refund_status,booking_cancellation_percentage: booking_cancellation_percentage) }
                        @message = "Refund processed successfully."

                        group_bookings_count = booking_group.bookings.count
                        group_cancel_bookings_count = booking_group.bookings.where("status = ? or status = ?","canceled","payment request canceled").count
                        partail_cancel = false
                        status = "canceled"
                        refund = booking_group.refund_amount + total_refund

                        #Checking BookingGroup have any canceled bookings
                        booking_group.booking_cancellation_percentage = booking_cancellation_percentage
                        booking_group.refund_amount = refund
                        booking_group.refund_status = refund_status
                        if group_cancel_bookings_count == group_bookings_count
                          message = "Booking group canceled and refund issued."
                        else
                          partail_cancel = true
                          status = 'partially canceled'
                          message = "Booking group partially canceled and refund issued."
                        end
                        booking_group.status = status
                        booking_group.save

                        UserMailer.booking_group_cancellation(booking_group,active_bookings.ids,partail_cancel,total_refund.to_f,refund_bonus.to_f,remaining_bonus.to_f,booking_cancellation_percentage.to_f,workspace_type).deliver_later
                      end#ActiveRecord::Base.transaction do
                    else
                      @message="Booking Already Canceled"
                    end#(@booking_group.status.eql?"confirmed" or @booking_group.status.eql?"visited" or @booking_group.status.eql?"partially canceled") and @booking_group.payment_status.eql?"paid"
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