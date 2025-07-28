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
            @booking_total_amount = @booking.total_amount
            @valid_workspace = true
            @refund_days = 7
            if @workspace_type.eql?"Weekly Pass"
              if Date.today > @booking.end_time.to_date
                @valid_workspace = false
              elsif Date.today > @booking.start_time.to_date
                differene = (@booking.start_time.to_date..Date.today).count{ |date| date.wday != 0 }
                @refund_days = 7 - differene
                @differene_amount = (differene * (@booking_total_amount/7.0)).round(2)
                @booking_total_amount = (@booking_total_amount - @differene_amount).round(2)
              end
            end#if @workspace_type.eql?"Weekly Pass"
            @fee_percentage = (@booking.booking_cancellation_percentage/100.0)
            @total_refund = (@booking_total_amount * (1 - @fee_percentage)).round(2)
            @cancelation_fee = (@booking_total_amount - @total_refund).round(2)
            @refund_bonus = 0
            @valid_workspace = true
            if @booking_group.present?
              if @booking_group.bonus_applied > 0
                proportion = @booking_total_amount / @booking_group.total_amount
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