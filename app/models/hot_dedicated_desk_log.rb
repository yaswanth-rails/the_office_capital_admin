class HotDedicatedDeskLog < ApplicationRecord
  include Current
  attr_accessor :current_toc  
  has_paper_trail on: [:update, :destroy], ignore: [:track_changes,:updated_at,:job_description], if: Proc.new { Current.toc }
	belongs_to :booking_group, optional: true
	belongs_to :invoice, optional: true
  belongs_to :payment_done_by, class_name: "User", optional: true
  belongs_to :coupon_applied_by, class_name: "User", optional: true

  scope :weekly_pass, -> {
    joins(booking_group: { bookings: { workspace: :workspace_type } })
      .where(workspace_types: { name: 'Weekly Pass' })
      .select('hot_dedicated_desk_logs.*')
      .group('hot_dedicated_desk_logs.id')
  }

  scope :hot_desk, -> {
    joins(booking_group: { bookings: { workspace: :workspace_type } })
      .where(workspace_types: { name: 'Hot Desk' })
      .select('hot_dedicated_desk_logs.*')
      .group('hot_dedicated_desk_logs.id')
  }

  scope :dedicated_desk, -> {
    joins(booking_group: { bookings: { workspace: :workspace_type } })
      .where(workspace_types: { name: 'Dedicated Desk' })
      .select('hot_dedicated_desk_logs.*')
      .group('hot_dedicated_desk_logs.id')
  }

  scope :private_office, -> {
    joins(booking_group: { bookings: { workspace: :workspace_type } })
      .where(workspace_types: { name: 'Private Office' })
      .select('hot_dedicated_desk_logs.*')
      .group('hot_dedicated_desk_logs.id')
  }

  def workspace_type
    booking_group.bookings.first&.workspace&.workspace_type&.name
  end
  rails_admin do
    list do
			scopes [:all, :weekly_pass, :hot_desk, :dedicated_desk, :private_office]
      field :id
      field :booking_group
      field :workspace_type do
        label 'Workspace Type'
        pretty_value do
          value
        end
      end
      field :action
      field :period_start
      field :period_end
      field :no_of_months
      field :payment_done_by
      field :coupon_applied_by
      field :invoice
      field :created_at
      field :updated_at
    end
  end
end
