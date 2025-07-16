class WalletHistory < ApplicationRecord
	belongs_to :wallet, optional: true
	belongs_to :user, optional: true
	belongs_to :deposit, optional: true
	belongs_to :withdraw, optional: true

  default_scope { order(:statement_date) } # FIFO
  scope :credits, -> { where(account_type: "bonus account").where('transaction_type = ?',"deposit bonus").where('action = ?', "credit") }
  scope :active, -> { where(account_type: "bonus account").where('transaction_type = ?',"deposit bonus").where('action = ?', "credit").where('statement_date >= ? AND used_amount < amount', 60.days.ago) }
  scope :used_entries, -> { where(account_type: "bonus account").where('transaction_type = ?',"deposit bonus").where('action = ?', "credit").where('statement_date >= ? AND used_amount > 0', 60.days.ago) }
  def remaining_amount
    return 0 if expired?
    [amount - used_amount, 0].max
  end

  def expired?
    statement_date < 60.days.ago
  end
  def available_amount
    amount - used_amount
  end

  rails_admin do
    list do
			field :id
      field :wallet
      field :user
      field :account_type
      field :amount
      field :action
      field :transaction_type
      field :reference_number
      field :statement_date
      field :bonus_expired
      field :created_at
      field :updated_at
      field :balance
      field :booking_id
      field :booking_group_id
      field :deposit
      field :deposit
      field :withdraw
    end
  end
end
