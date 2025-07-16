class Wallet < ApplicationRecord
  include Current
  attr_accessor :current_toc
  has_paper_trail on: [:update, :destroy], ignore: [:track_changes,:updated_at], if: Proc.new { Current.toc }
  attr_accessor :executed
  after_update :track_changes_in_table, unless: :executed
	belongs_to :company, optional: true
	has_many :wallet_histories

	ZERO = 0.to_d
	validates_numericality_of :balance, greater_than_or_equal_to: ZERO
	validates :company_id, uniqueness: {allow_nil: true, allow_blank: true}
  rails_admin do
    edit do
      field :company do
				read_only true
			end
      field :ban_withdraw
      field :enable_withdraw
      field :ban_withdraw_reason
      field :ban_deposit
      field :enable_deposit
      field :ban_deposit_reason
    end

    list do
    	field :id
      field :company
      field :balance
      field :bonus_balance
      field :created_at
      field :updated_at
      field :ban_withdraw
      field :enable_withdraw
      field :ban_withdraw_reason
      field :ban_deposit
      field :enable_deposit
      field :ban_deposit_reason
    end
  end
  private
    def track_changes_in_table
      if Current.toc.present? && self.saved_changes.present? 
        row = Wallet.find(self.id)
        version = PaperTrail::Version.where('item_type=? and item_id=? and whodunnit=?','Wallet',self.id,Current.toc.id.to_s).last.object_changes rescue nil
        if version.present?
          version_data = version.gsub("\n"," ").gsub("--- ","")
          message = "Admin #{Current.toc.email} with id '#{Current.toc.id}' updated the following fields of Wallet '#{row.id}'"+' '+version_data
          subject = "Admin  with id '#{Current.toc.id}', role #{Current.toc.role.role} updated Wallet table. [#{Time.zone.now.strftime('%H:%M:%S %Z')}]"
          latest_changes = []
          latest_changes << version_data
          latest_changes << Current.toc.email[0..3]+""+Current.toc.id.to_s+" "+Time.zone.now.strftime("%d/%m/%Y %H:%M")
          all_changes = (row.track_changes + latest_changes).flatten
          row.track_changes = all_changes
          row.executed = true
          row.save!(validate:false)
          UserMailer.track_changes(message,subject).deliver_later
        end#@version.present?
      end#Current.toc.present? && self.saved_changes.present? 
    end#track_changes_in_table 
end
