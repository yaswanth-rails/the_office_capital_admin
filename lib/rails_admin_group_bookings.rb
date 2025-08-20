require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'
 
module RailsAdminGroupBookings
end

module RailsAdmin
  module Config
    module Actions
      class GroupBookings < RailsAdmin::Config::Actions::Base
        register_instance_option :visible? do
          authorized?
        end

        register_instance_option :link_icon do
          'fa fa-list'
        end

        register_instance_option :member? do
          true
        end

        register_instance_option :controller do
          Proc.new do
            @booking_group = BookingGroup.find(params[:id])
            @bookings = @booking_group.bookings.order("id asc").page(params[:page]).per(20) rescue nil
            @booking = @booking_group.bookings.first
            @workspace = @booking.workspace
            @workspace_type = @workspace.workspace_type
            @booking_logs = @booking_group.hot_dedicated_desk_logs
          end
        end
      end
    end
  end
end  