class BookingGroup < ApplicationRecord
  include Current
  attr_accessor :current_toc  
  has_paper_trail on: [:update, :destroy], ignore: [:track_changes,:updated_at], if: Proc.new { Current.toc }
  attr_accessor :executed
  after_update :track_changes_in_table, unless: :executed

  belongs_to :group
  belongs_to :created_by, class_name: "User"
  belongs_to :payment_done_by, class_name: "User", optional: true
  belongs_to :coupon_applied_by, class_name: "User", optional: true
  belongs_to :canceled_by, class_name: "User", optional: true
  has_many :bookings, dependent: :destroy
  has_many :invoices, dependent: :destroy
  belongs_to :coupon, optional: true

  def refund_status_enum
    [[nil],['refund pending'],['refunded']]
  end#refund_status_enum
  def status_enum
    [['payment requested'],['payment requst canceled'],['confirmed'],['canceled'],['visited']]
  end#status_enum

  def workspace_type
    bookings.first&.workspace&.workspace_type&.name
      # .includes(workspace: :workspace_type)
      # .map { |b| b.workspace&.workspace_type&.name }
      # .compact
      # .uniq
  end

  scope :desk, -> {
    joins(bookings: { workspace: :workspace_type })
      .where(workspace_types: { name: 'Desk' })
      .select('DISTINCT ON (booking_groups.id) booking_groups.*')
  }

  scope :weekly_pass, -> {
    joins(bookings: { workspace: :workspace_type })
      .where(workspace_types: { name: 'Weekly Pass' })
      .select('DISTINCT ON (booking_groups.id) booking_groups.*')
  }

  scope :hot_desk, -> {
    joins(bookings: { workspace: :workspace_type })
      .where(workspace_types: { name: 'Hot Desk' })
      .select('DISTINCT ON (booking_groups.id) booking_groups.*')
  }

  scope :dedicated_desk, -> {
    joins(bookings: { workspace: :workspace_type })
      .where(workspace_types: { name: 'Dedicated Desk' })
      .select('DISTINCT ON (booking_groups.id) booking_groups.*')
  }

  rails_admin do
    edit do
      field :group do
        read_only true
      end
      field :created_by do
        read_only true
      end
      field :total_amount do
        read_only true
      end
      field :tax do
        read_only true
      end
      field :status do
        read_only true
      end
      field :booking_cancellation_percentage do
        read_only true
      end
      field :refund_status do
        read_only true
      end
    end

    list do
      scopes [:all, :desk, :weekly_pass, :hot_desk, :dedicated_desk]
      field :id
      field :group
      field :created_by
      field :workspace_type do
        label 'Workspace Type'
        pretty_value do
          value
        end
      end
      field :amount
      field :net_amount
      field :tax
      field :total_amount
      field :status
      field :payment_status
      field :payment_type
      field :razorpay_order_id
      field :razorpay_payment_id
      field :created_at
      field :updated_at
      field :wallet_applied
      field :bonus_applied
      field :payment_done_by
      field :coupon
      field :coupon_discount
      field :coupon_applied_by
      field :booking_cancellation_percentage
      field :refund_status
      field :refund_amount
      field :canceled_by
      field :canceled_at
      field :refund_remarks
      field :unsubscribe_alert
      field :next_invoice_date
    end
  end
  def track_changes_in_table
    if Current.toc.present? && self.saved_changes.present?
      row = BookingGroup.find(self.id)
      version = PaperTrail::Version.where('item_type=? and item_id=? and whodunnit=?','BookingGroup',self.id,Current.toc.id.to_s).last.object_changes rescue nil
      if version.present?
        version_data = version.gsub("\n"," ").gsub("--- ","")
        message = "Admin #{Current.toc.email} with id '#{Current.toc.id}' updated the following fields of BookingGroup '#{row.id}'"+' '+version_data
        subject = "Admin  with id '#{Current.toc.id}', role #{Current.toc.role.role} updated BOOKING GROUP table. [#{Time.zone.now.strftime('%H:%M:%S %Z')}]"
        latest_changes = []
        latest_changes << version_data
        latest_changes << Current.toc.email[0..3]+""+Current.toc.id.to_s+" "+Time.zone.now.strftime("%d/%m/%Y %H:%M")
        all_changes = (row.track_changes + latest_changes).flatten
        row.track_changes = all_changes
        row.executed = true
        row.save!
        UserMailer.track_changes(message,subject).deliver_later
      end#version.present?
    end#Current.toc.present? && self.saved_changes.present?
  end#track_changes_in_table

end
