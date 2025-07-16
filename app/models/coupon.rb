class Coupon < ApplicationRecord
  include Current
  attr_accessor :current_toc  
  has_paper_trail on: [:update, :destroy], ignore: [:track_changes,:updated_at,:job_description], if: Proc.new { Current.toc }
  validates_presence_of :coupon_code
  validates_uniqueness_of :coupon_code
  validates_presence_of :max_times
  validates_presence_of :max_times_per_day
  attr_accessor :executed
  after_update :track_changes_in_table, unless: :executed
  has_many :user_coupon_uses
  has_many :users, through: :user_coupon_uses
  belongs_to :user, optional: true
  has_many :bookings
  has_many :booking_groups

  def coupon_type_enum
    [['amount'],['percentage']]
  end#coupon_type_enum

  rails_admin do
    edit do
      field :coupon_code
      field :enabled
      field :coupon_type
      field :discount_amount
      field :discount_percent
      field :max_discount
      field :max_times
      field :max_times_per_day
      field :user
      field :starts_at
      field :expires_at
    end#edit
    list do
      field :id
      field :coupon_code
      field :enabled
      field :coupon_type
      field :discount_amount
      field :discount_percent
      field :max_discount
      field :max_times
      field :max_times_per_day
      field :user
      field :starts_at
      field :expires_at
      field :created_at
      field :updated_at
    end#edit
  end

  def track_changes_in_table
    if Current.toc.present? && self.saved_changes.present? 
      row = Coupon.find(self.id)
      version = PaperTrail::Version.where('item_type=? and item_id=? and whodunnit=?','Coupon',self.id,Current.toc.id.to_s).last.object_changes rescue nil
      if version.present?
        version_data = version.gsub("\n"," ").gsub("--- ","")
        message = "Admin #{Current.toc.email} with id '#{Current.toc.id}' updated the following fields of Coupon '#{row.id}'"+' '+version_data
        subject = "Admin  with id '#{Current.toc.id}', role #{Current.toc.role.role} updated Coupon table"
        latest_changes = []
        latest_changes << version_data
        latest_changes << Current.toc.email[0..3]+""+Current.toc.id.to_s+" "+Time.zone.now.strftime("%d/%m/%Y %H:%M")
        row.track_changes = (row.track_changes + latest_changes).flatten
        row.executed = true
        row.save!(validate:false)
        UserMailer.track_changes(message,subject).deliver_later
      end#version.present?
    end#Current.toc.present? && self.saved_changes.present? 
  end#track_changes_in_table 
end
