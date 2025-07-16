require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'
 
module RailsAdminRefund
end

module RailsAdmin
  module Config
    module Actions
      class Refund < RailsAdmin::Config::Actions::Base
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
            @booking = Booking.find(params[:id])
            @booking_group = @booking&.booking_group
            @workspace = @booking.workspace
            @workspace_type = @workspace.workspace_type.name
            @fee_percentage = (@booking.booking_cancellation_percentage/100.0)
            @total_refund = (@booking.total_amount * (1 - @fee_percentage)).round(2)
            @cancelation_fee = (@booking.total_amount - @total_refund).round(2)
            @refund_bonus = 0
            if @booking_group.present?
              if @booking_group.bonus_applied > 0
                proportion = @booking.total_amount / @booking_group.total_amount
                @refund_bonus = (@booking_group.bonus_applied * proportion).round(2)
              end
            else
              @refund_bonus = @booking.bonus_applied
            end#if @booking_group.present?
            @wallet_applied = (@total_refund - @refund_bonus)
          end#Proc.new do
        end
      end
    end
  end
end