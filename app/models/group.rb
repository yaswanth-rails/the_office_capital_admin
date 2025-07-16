class Group < ApplicationRecord
  include Current
  attr_accessor :current_toc  
  has_paper_trail on: [:update, :destroy], ignore: [:track_changes,:updated_at], if: Proc.new { Current.toc }
  attr_accessor :executed
  after_update :track_changes_in_table, unless: :executed

  has_many :users
  has_many :external_guests
  belongs_to :company
  has_many :bookings, through: :users
  has_many :booking_groups
	validates :name, presence: true

  rails_admin do
    edit do
      field :name
      field :company_id
      field :allow_meeting_room_booking
      field :spend_limit
      field :status
      field :external_guests_allowed
    end

    list do
      field :id
      field :name
      field :company
      field :spend_limit
      field :booking_settings
      field :status
      field :external_guests_allowed
      field :created_at
      field :updated_at
    end
  end

  def track_changes_in_table
    if Current.toc.present? && self.saved_changes.present? 
      row = Group.find(self.id)
      version = PaperTrail::Version.where('item_type=? and item_id=? and whodunnit=?','Group',self.id,Current.toc.id.to_s).last.object_changes rescue nil
      if version.present?
        version_data = version.gsub("\n"," ").gsub("--- ","")
        message = "Admin #{Current.toc.email} with id '#{Current.toc.id}' updated the following fields of Group '#{row.id}'"+' '+version_data
        subject = "Admin  with id '#{Current.toc.id}', role #{Current.toc.role.role} updated GROUP table"
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
