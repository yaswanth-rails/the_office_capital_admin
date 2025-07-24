class Booking < ApplicationRecord
  include Current
  attr_accessor :current_toc  
  has_paper_trail on: [:update, :destroy], ignore: [:track_changes,:updated_at], if: Proc.new { Current.toc }
  attr_accessor :executed
  after_update :track_changes_in_table, unless: :executed

  belongs_to :user, optional: true
  belongs_to :external_guest, optional: true
  belongs_to :workspace
  has_one :workspace_type, through: :workspace
  belongs_to :booking_group
  belongs_to :coupon, optional: true
  belongs_to :coupon_applied_by, class_name: "User", optional: true
  belongs_to :canceled_by, class_name: "User", optional: true
  belongs_to :payment_done_by, class_name: "User", optional: true
  delegate :group, to: :user
  validates :start_time, :end_time, :status, presence: true

  def refund_status_enum
    [[nil],['refund pending'],['refunded']]
  end#refund_status_enum

  def status_enum
    [['payment requested'],['payment request canceled'],['confirmed'],['canceled'],['partially canceled'],['visited']]
  end#status_enum

  def workspace_type_name
    workspace&.workspace_type&.name
  end

  scope :desk, -> { joins(workspace: :workspace_type).where(workspace_types: { name: 'Desk' }) }
  scope :meeting_room, -> { joins(workspace: :workspace_type).where(workspace_types: { name: 'Meeting Room' }) }
  scope :weekly_pass, -> { joins(workspace: :workspace_type).where(workspace_types: { name: 'Weekly Pass' }) }
  scope :hot_desk, -> { joins(workspace: :workspace_type).where(workspace_types: { name: 'Hot Desk' }) }
  scope :dedicated_desk, -> { joins(workspace: :workspace_type).where(workspace_types: { name: 'Dedicated Desk' }) }


  rails_admin do
    edit do
      field :workspace do
        read_only true
      end
      field :start_time do
        read_only true
      end
      field :end_time do
        read_only true
      end
      field :hours do
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
      field :total_amount do
        read_only true
      end
    end
    list do
      scopes [:all,:desk,:meeting_room,:weekly_pass,:hot_desk,:dedicated_desk]
      field :id
      field :user
      field :external_guest
      field :booking_group
      field :workspace
      # field :workspace_type_name do
      #   label 'Workspace Type'
      #   searchable false
      #   sortable false
      #   filterable false
      # end
      field :workspace_type do
        label "Workspace Type"
        searchable ['workspace_types.name']
        queryable true
        filterable true
        pretty_value do
          bindings[:object].workspace&.workspace_type&.name
        end
      end
      field :reference_number
      field :amount
      field :net_amount
      field :tax
      field :total_amount
      field :start_time
      field :end_time
      field :quantity
      field :no_of_months
      field :hours
      field :meeting_room_guests
      field :status
      field :payment_status
      field :payment_type
      field :created_at
      field :updated_at
      field :razorpay_order_id
      field :razorpay_payment_id
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
    end
  end
  def track_changes_in_table
    if Current.toc.present? && self.saved_changes.present? 
      row = Booking.find(self.id)
      version = PaperTrail::Version.where('item_type=? and item_id=? and whodunnit=?','Booking',self.id,Current.toc.id.to_s).last.object_changes rescue nil
      if version.present?
        version_data = version.gsub("\n"," ").gsub("--- ","")
        message = "Admin #{Current.toc.email} with id '#{Current.toc.id}' updated the following fields of Booking '#{row.id}'"+' '+version_data
        subject = "Admin  with id '#{Current.toc.id}', role #{Current.toc.role.role} updated BOOKING table. [#{Time.zone.now.strftime('%H:%M:%S %Z')}]"
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
