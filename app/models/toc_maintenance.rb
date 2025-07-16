class TocMaintenance < ApplicationRecord
  include Current
  attr_accessor :current_toc
  has_paper_trail on: [:update, :destroy],ignore: [:tn,:en,:tel,:hnd,:track_changes,:updated_at],  if: Proc.new { Current.toc }
  attr_accessor :executed
  after_update :track_changes_in_table, unless: :executed
	after_update :update_language_files

	def inr_withdraw_period_label_enum
   		[['Daily'],['Weekly'],['Monthly']]
	end#status_enum

  rails_admin do
    list do
      field :id
      field :booking_cancellation_percentage
      field :min_deposit
      field :min_withdraw
      field :withdraw_fee
      field :deposit_maintenance
      field :deposit_maintenance_message
      field :withdraw_maintenance
      field :withdraw_maintenance_message
      field :inr_withdraw_limit
      field :inr_withdraw_period
      field :inr_withdraw_period_label
      field :desk_booking_maintenance
      field :desk_booking_maintenance_message
      field :meeting_room_booking_maintenance
      field :meeting_room_booking_maintenance_message
      field :gst_for_bookings
      field :bonus_percentage_ten_thousand_above_deposits
      field :bonus_percentage_one_lakh_above_deposits
      field :bonus_usage_percentage
      # field :en
      # field :tel
      # field :hnd
      # field :tn
    end
    edit do
      field :booking_cancellation_percentage
      field :min_deposit
      field :min_withdraw
      field :withdraw_fee
      field :deposit_maintenance
      field :deposit_maintenance_message
      field :withdraw_maintenance
      field :withdraw_maintenance_message
      field :inr_withdraw_limit
      field :inr_withdraw_period
      field :inr_withdraw_period_label
      field :desk_booking_maintenance
      field :desk_booking_maintenance_message
      field :meeting_room_booking_maintenance
      field :meeting_room_booking_maintenance_message
      field :gst_for_bookings
      field :bonus_percentage_ten_thousand_above_deposits
      field :bonus_percentage_one_lakh_above_deposits
      field :bonus_usage_percentage
      field :deposit_notes, :ck_editor
      # field :en,:text do
      #   html_attributes rows: 30, cols: 80
      # end
      # field :tel,:text do
      #   html_attributes rows: 30, cols: 80
      # end
      # field :hnd,:text do
      #   html_attributes rows: 30, cols: 80
      # end
      # field :tn,:text do
      #   html_attributes rows: 30, cols: 80
      # end
    end#edit do
  end#rails_admin    

	private

  def track_changes_in_table
    if Current.toc.present? && self.saved_changes.present? 
      @row = TocMaintenance.find(self.id)
      @version = PaperTrail::Version.where('item_type=? and item_id=? and whodunnit=?','TocMaintenance',self.id,Current.toc.id.to_s).last.object_changes rescue nil
      if @version.present?
        version=@version.gsub("\n"," ").gsub("--- ","")
        message = "Admin #{Current.toc.email} with id '#{Current.toc.id}' updated the following fields of TocMaintenance '#{@row.id}'"+' '+version
        subject = "Admin  with id '#{Current.toc.id}', role #{Current.toc.role.role} updated TocMaintenance table [ requested at #{Time.zone.now.strftime("%H:%M:%S")} ]"
        latest_changes = []
        latest_changes << version
        latest_changes << Current.toc.email[0..3]+""+Current.toc.id.to_s+" "+Time.now.strftime("%d/%m/%Y %H:%M")
        all_changes = (@row.track_changes + latest_changes).flatten
        @row.track_changes = all_changes
        @row.executed = true
        @row.save!
        UserMailer.track_changes(message,subject).deliver_later
      end#@version.present?
    end#Current.toc.present? && self.saved_changes.present? 
  end#track_changes_in_table

	def update_language_files
    if en_previously_changed? && persisted?
      en_file = File.open(File.join(Dir.pwd, "/public/en.json"),"w")
      en_file.puts(self.en)
      en_file.close
      # File.open("public/en.json","w") do |f|
      #   f.write(self.en.to_json)
      # end      
    end
    if tel_previously_changed? && persisted?
      en_file = File.open(File.join(Dir.pwd, "/public/tel.json"),"w")
      en_file.puts(self.tel)
      en_file.close      
      # File.open("public/tel.json","w") do |f|
      #   f.write(self.tel.to_json)
      # end
    end
    if hnd_previously_changed? && persisted?
      en_file = File.open(File.join(Dir.pwd, "/public/hnd.json"),"w")
      en_file.puts(self.hnd)
      en_file.close
      # File.open("public/hnd.json","w") do |f|
      #   f.write(self.hnd.to_json)
      # end
    end
    if tn_previously_changed? && persisted?
      tn_file = File.open(File.join(Dir.pwd, "/public/tn.json"),"w")
      tn_file.puts(self.tn)
      tn_file.close
      # File.open("public/tn.json","w") do |f|
      #   f.write(self.tn.to_json)
      # end
    end
	end
end
