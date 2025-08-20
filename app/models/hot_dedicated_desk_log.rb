class HotDedicatedDeskLog < ApplicationRecord
  include Current
  attr_accessor :current_toc  
  has_paper_trail on: [:update, :destroy], ignore: [:track_changes,:updated_at,:job_description], if: Proc.new { Current.toc }
	belongs_to :booking_group, optional: true
	belongs_to :invoice, optional: true
  belongs_to :payment_done_by, class_name: "User", optional: true
  belongs_to :coupon_applied_by, class_name: "User", optional: true
  rails_admin do
    list do
      field :id
      field :booking_group
      field :action
      field :period_start
      field :period_end
      field :no_of_months
      field :payment_done_by
      field :coupon_applied_by
      field :invoice
    end
  end
end
