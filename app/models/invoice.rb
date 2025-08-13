class Invoice < ApplicationRecord
  include Current
  attr_accessor :current_toc  
  has_paper_trail on: [:update, :destroy], ignore: [:track_changes,:updated_at,:job_description], if: Proc.new { Current.toc }
  attr_accessor :executed
  after_update :track_changes_in_table, unless: :executed

  belongs_to :booking_group
  belongs_to :user

  validates :amount, :due_date, presence: true
  validates :reference_number, uniqueness: true

  scope :due_soon, -> { where(status: "pending").where("due_date <= ?", 3.days.from_now) }
  scope :overdue, -> { where(status: "pending").where("due_date < ?", Date.today) }

  rails_admin do
    list do
      field :id
      field :booking_group
      field :user
      field :period_start
      field :period_end
      field :amount
      field :net_amount
      field :tax
      field :total_amount
      field :status
      field :reference_number
      field :due_date
      field :paid_at
      field :created_at
      field :updated_at
      field :payment_type
      field :razorpay_order_id
      field :razorpay_payment_id
      field :wallet_applied
      field :bonus_applied
    end
  end

  def track_changes_in_table
    if Current.toc.present? && self.saved_changes.present? 
      row = Invoice.find(self.id)
      version = PaperTrail::Version.where('item_type=? and item_id=? and whodunnit=?','Invoice',self.id,Current.toc.id.to_s).last.object_changes rescue nil
      if version.present?
        version_data = version.gsub("\n"," ").gsub("--- ","")
        message = "Admin #{Current.toc.email} with id '#{Current.toc.id}' updated the following fields of Invoice '#{row.id}'"+' '+version_data
        subject = "Admin  with id '#{Current.toc.id}', role #{Current.toc.role.role} updated INVOICE table"
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
