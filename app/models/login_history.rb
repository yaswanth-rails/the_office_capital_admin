class LoginHistory < ApplicationRecord
  include Current
  attr_accessor :current_toc  
  has_paper_trail on: [:update, :destroy], ignore: [:track_changes,:updated_at], if: Proc.new { Current.toc }
  attr_accessor :executed
  after_update :track_changes_in_table, unless: :executed
	belongs_to :user, optional: true 
  
  rails_admin do
    list do
      field :id
      field :user
      field :ip_address
      field :country
      field :region
      field :city
      field :browser
      field :os
      field :created_at
      field :updated_at
      field :source
      field :forgot_password
      field :devise_id
    end
  end

  def track_changes_in_table
    if Current.toc.present? && self.saved_changes.present? 
      row = LoginHistory.find(self.id)
      version = PaperTrail::Version.where('item_type=? and item_id=? and whodunnit=?','LoginHistory',self.id,Current.toc.id.to_s).last.object_changes rescue nil
      if version.present?
        version_data = version.gsub("\n"," ").gsub("--- ","")
        message = "Admin #{Current.toc.email} with id '#{Current.toc.id}' updated the following fields of User '#{row.id}'"+' '+version_data
        subject = "Admin  with id '#{Current.toc.id}', role #{Current.toc.role.role} updated USER table"
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
