class Withdraw < ApplicationRecord
  include Current
  attr_accessor :current_toc  
  has_paper_trail on: [:update, :destroy], ignore: [:track_changes,:updated_at], if: Proc.new { Current.toc }
  attr_accessor :executed
  after_update :track_changes_in_table, unless: :executed
  after_update :update_credit_status
  validate :check_status
  belongs_to :bank_account, optional: true 
  belongs_to :user, optional: true 

  has_many :wallet_histories

  validates :amount,:fee, numericality: { greater_than: 0 }
  validates :reference_number, uniqueness: true

  def status_enum
    [['pending'],['canceled'],['inprogress'],['credited to user'],['transaction error']]
  end#status_enum
  def master_wallet_status_enum
    [['debited from master wallet']]
  end#master_wallet_status_enum 


  rails_admin do
    list do
      field :id
      field :user
      field :bank_account
      field :reference_number
      field :status
      field :created_at
      field :updated_at
      field :withdraw_amount
      field :fee
      field :amount
      # field :master_wallet_status
      field :cancel_reason
      field :bank_name
      field :track_changes do 
        visible do
          Current.toc.role.role.eql?"superadmin"
        end
      end     
    end#list do
    show do
      field :id
      field :user
      field :bank_account
      field :reference_number
      field :status
      field :created_at
      field :updated_at
      field :withdraw_amount
      field :fee
      field :amount
      # field :master_wallet_status
      field :cancel_reason
      field :bank_name  
      field :versions
      field :account_transactions
      field :track_changes do 
        visible do
          Current.toc.role.role.eql?"superadmin"
        end
      end   
    end#show do   
    edit do
      field :user_id  do
        read_only true
      end
      field :bank_account_id  do
        read_only true
      end
      field :withdraw_amount  do
        read_only true
      end
      field :fee  do
        read_only true
      end
      field :amount  do
        read_only true
      end
      field :reference_number do 
        read_only true
      end
      # field :master_wallet_status do
      #   read_only do
      #     bindings[:object].status.eql?('canceled') or bindings[:object].status.eql?('credited to user') or bindings[:object].status.eql?('transaction error')
      #   end
      # end
      field :status do
        read_only do
          bindings[:object].status.eql?('canceled') or bindings[:object].status.eql?('credited to user') or bindings[:object].status.eql?('transaction error')
        end
      end
      field :cancel_reason
      field :bank_name      
    end#edit do
  end#rails_admin

  private
    def check_status
      errors.add(:status, "Withdraw Already Canceled/Credited to User") if status_was.eql?"canceled" or status_was.eql?"credited to user"
    end

    def track_changes_in_table
      if Current.toc.present? && self.saved_changes.present? 
        row = Withdraw.find(self.id)
        version = PaperTrail::Version.where('item_type=? and item_id=? and whodunnit=?','Withdraw',self.id,Current.toc.id.to_s).last.object_changes rescue nil
        if version.present?
          version_data = version.gsub("\n"," ").gsub("--- ","")
          message = "Admin #{Current.toc.email} with id '#{Current.toc.id}' updated the following fields of Withdraw '#{row.id}'"+' '+version_data
          subject = "Admin  with id '#{Current.toc.id}', role #{Current.toc.role.role} updated Withdraw table"
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

    def update_credit_status
    if saved_changes?
      if status_previously_changed? and persisted? and self.status.eql? "credited to user"
        master_wallet = Wallet.find(ENV["TOC_MASTER_WALLET"])
        master_wallet.transaction do
          master_wallet.with_lock do
            master_wallet.balance = (master_wallet.balance - self.withdraw_amount).round(2)
            if master_wallet.save
              self.master_wallet_status = "debited from master wallet"
              self.executed = true
              self.save
              WalletHistory.create(:account_type=> "inr account",:wallet_id=> master_wallet.id,:statement_date=> Time.zone.now,:transaction_type=>"withdraw",:amount=>self.withdraw_amount,:action=>"debit",:balance=> master_wallet.balance,:withdraw_id=>self.id,:reference_number=>self.reference_number)
            end#if master_wallet.save
          end
        end#master_wallet.transaction do
        UserMailer.send_withdraw_confirmation(user,self).deliver_later
      elsif status_previously_changed? and persisted? and self.status.eql? "canceled"
        if self.user.present?
          master_wallet = Wallet.where("company_id=?",ENV["TOC_MASTER_WALLET"]).first #Live Master inr account
          user_wallet = Wallet.where("company_id=?",user.group.company_id).first
          user_wallet.transaction do
            user_wallet.with_lock do
              #Crediting INR value from user
              user_wallet.balance = (user_wallet.balance + self.amount).round(2)
              if user_wallet.save!(validate:false)
                #Adding user's inr account credit transaction
                WalletHistory.create(:user_id=>self.user_id,:account_type=> "inr account",:wallet_id=> user_wallet.id,:statement_date=> Time.zone.now,:transaction_type=>"withdraw cancel",:amount=>self.amount,:action=>"credit",:balance=> user_wallet.balance,:withdraw_id=>self.id,:reference_number=>self.reference_number)
                #deducting FEE from master inr account
                master_wallet.balance = (master_wallet.balance - self.fee).round(2)
                if master_wallet.save
                  WalletHistory.create(:account_type=> "inr account",:wallet_id=> master_wallet.id,:statement_date=> Time.zone.now,:transaction_type=>"withdraw fee refund",:amount=>self.fee,:action=>"debit",:balance=> master_wallet.balance,:withdraw_id=>self.id,:reference_number=>self.reference_number)
                end#if master_wallet.save
                #ALERT TO USER
                UserMailer.send_cancel_withdraw_alert(self).deliver_later
              end#if user_wallet.save!
            end#Lock
          end#Transaction
        end#if self.user.present?
      end#if changed.include? 'status' and self.status.eql? "credited to user"
    end#if saved_changes?
  end#update_credit_status 
end#Withdraw