class WorkspaceTiming < ApplicationRecord
  include Current
  attr_accessor :current_toc  
  has_paper_trail on: [:update, :destroy], ignore: [:track_changes,:updated_at], if: Proc.new { Current.toc }
  attr_accessor :executed
  after_update :track_changes_in_table, unless: :executed

  belongs_to :workspace
  validates :day_of_week, inclusion: { in: 0..6 } # 0 = Sunday
  validates :day_of_week, uniqueness: {scope: :workspace_id}

  def day_of_week_enum
    [[0],[1],[2],[3],[4],[5],[6]]
  end#day_of_week_enum

  rails_admin do
    edit do
      field :workspace
      field :day_of_week
      field :open_time
      field :close_time
      field :is_closed
    end

    list do
      field :id
      field :workspace
      field :day_of_week
      field :open_time
      field :close_time
      field :is_closed
      field :created_at
      field :updated_at
    end
  end

  def track_changes_in_table
    if Current.toc.present? && self.saved_changes.present? 
      row = WorkspaceTiming.find(self.id)
      version = PaperTrail::Version.where('item_type=? and item_id=? and whodunnit=?','WorkspaceTiming',self.id,Current.toc.id.to_s).last.object_changes rescue nil
      if version.present?
        version_data = version.gsub("\n"," ").gsub("--- ","")
        message = "Admin #{Current.toc.email} with id '#{Current.toc.id}' updated the following fields of WorkspaceTiming '#{row.id}'"+' '+version_data
        subject = "Admin  with id '#{Current.toc.id}', role #{Current.toc.role.role} updated WORKSPACE TIMINGS table"
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
