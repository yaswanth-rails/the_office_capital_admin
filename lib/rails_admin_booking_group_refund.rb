require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'
 
module RailsAdminBookingGroupRefund
end

module RailsAdmin
  module Config
    module Actions
      class BookingGroupRefund < RailsAdmin::Config::Actions::Base
        register_instance_option :visible? do
          authorized?
        end

        register_instance_option :link_icon do
          'fa fa-undo'
        end

        register_instance_option :member? do
          true
        end

        register_instance_option :controller do
          Proc.new do
            @booking_group = BookingGroup.includes(:bookings).find(params[:id])
            @first_booking = @booking_group.bookings.first
            @workspace = @first_booking.workspace
            @workspace_type = @workspace.workspace_type.name
            @active_bookings = @booking_group.bookings.where("status =?","confirmed")
            @valid_workspace = true
            @refund_days = 7
            @fee_percentage = (@booking_group.booking_cancellation_percentage/100.0)
            @bookings = @booking_group.bookings

            if @active_bookings.present?
              @active_bookings_total_amount = @active_bookings.sum(:total_amount)
              if @workspace_type.eql?"Weekly Pass"
                if Date.today > @first_booking.end_time.to_date
                  @valid_workspace = false
                elsif Date.today > @first_booking.start_time.to_date
                  differene = (@first_booking.start_time.to_date..Date.today).count{ |date| date.wday != 0 }
                  @refund_days = 7 - differene
                  @differene_amount = (differene * (@first_booking.total_amount/7.0)).round(2)
                  @active_bookings_total_amount = (@active_bookings_total_amount - (@differene_amount * @active_bookings.count)).round(2)
                end
              end#if @workspace_type.eql?"Weekly Pass"
              @total_refund = (@active_bookings_total_amount * (1 - @fee_percentage)).round(2)

              @refund_bonus = 0
              if @booking_group.bonus_applied > 0
                proportion = @active_bookings_total_amount / @booking_group.total_amount
                @refund_bonus = (@booking_group.bonus_applied * proportion).round(2)
              end
              @wallet_applied = (@total_refund - @refund_bonus)
              @cancelation_fee = (@active_bookings_total_amount - @total_refund).round(2)
            else
              @total_refund = @booking_group.refund_amount
              @refund_bonus = @booking_group.bonus_applied
              @wallet_applied = (@total_refund - @refund_bonus)
              @cancelation_fee = (@booking_group.total_amount - @total_refund).round(2)
            end#if @active_bookings.present?
          end#Proc.new do
        end
      end
    end
  end
end