class Workspace < ApplicationRecord
  include Current
  attr_accessor :current_toc  
  has_paper_trail on: [:update, :destroy], ignore: [:track_changes,:updated_at], if: Proc.new { Current.toc }
  attr_accessor :executed
  after_update :track_changes_in_table, unless: :executed

  belongs_to :workspace_type
  belongs_to :street
  belongs_to :location
  has_many :workspace_amenities, dependent: :destroy
  has_many :amenities, through: :workspace_amenities
  has_many :workspace_equipments, dependent: :destroy
  has_many :equipment, class_name: "Equipment", through: :workspace_equipments

  has_many :workspace_timings
  has_many :bookings
  has_many :reviews

  mount_uploader :image1, WorkspaceUploader
  mount_uploader :image2, WorkspaceUploader
  mount_uploader :image3, WorkspaceUploader
  mount_uploader :image4, WorkspaceUploader
  mount_uploader :image5, WorkspaceUploader

  delegate :location, to: :street

  # validates :name, :price_per_hour, presence: true

  scope :with_amenities, ->(amenity_ids) {
    joins(:workspace_amenities).where(workspace_amenities: { amenity_id: amenity_ids }).distinct
  }

  scope :with_equipments, ->(equipment_ids) {
    joins(:workspace_equipments).where(workspace_equipments: { equipment_id: equipment_ids }).distinct
  }

  rails_admin do
    edit do
      field :workspace_type
      field :location_id, :enum do
        enum do
          Location.all.collect {|l| [l.city, l.id]}
        end
      end
      field :street
      field :title
      field :permalink
      field :name
      field :floor
      field :capacity
      field :metro_connectivity
      field :address
      field :latitude
      field :longitude
      field :price_per_hour
      field :price
      field :description
      field :workspace_highlights, :ck_editor
      field :image1
      field :image2
      field :image3
      field :image4
      field :image5
    end

    list do
      field :id
      field :workspace_type
      field :location
      field :street
      field :title
      field :name
      field :floor
      field :capacity
      field :metro_connectivity
      field :address
      field :latitude
      field :longitude
      field :price_per_hour
      field :price
      field :description
      field :image1
      field :image2
      field :image3
      field :image4
      field :image5
      field :created_at
      field :updated_at
    end
  end

  def track_changes_in_table
    if Current.toc.present? && self.saved_changes.present? 
      row = Workspace.find(self.id)
      version = PaperTrail::Version.where('item_type=? and item_id=? and whodunnit=?','Workspace',self.id,Current.toc.id.to_s).last.object_changes rescue nil
      if version.present?
        version_data = version.gsub("\n"," ").gsub("--- ","")
        message = "Admin #{Current.toc.email} with id '#{Current.toc.id}' updated the following fields of Workspace '#{row.id}'"+' '+version_data
        subject = "Admin  with id '#{Current.toc.id}', role #{Current.toc.role.role} updated WORKSPACE table"
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
