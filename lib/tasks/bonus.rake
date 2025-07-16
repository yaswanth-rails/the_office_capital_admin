namespace :bonus do
  desc "Expire old bonuses across all wallets"
  task expire_old_credits: :environment do
    puts "[#{Time.current}] Starting bonus expiry check..."
    expired_transactions = WalletHistory.where("account_type = ? and action =? and statement_date < ? and bonus_expired = ? and transaction_type != ?","bonus account","credit",60.days.ago,false,"bonus refund")
    if expired_transactions.present?
      expired_transactions.each do |expired_transaction|
        unused = expired_transaction.amount - expired_transaction.used_amount
        if unused <= 0
          expired_transaction.bonus_expired = true
          expired_transaction.save
        else
          wallet = expired_transaction.wallet
          ActiveRecord::Base.transaction do
            wallet.with_lock do
              wallet.balance = (wallet.balance - unused).round(2)
              if wallet.save
                expired_transaction.bonus_expired = true
                expired_transaction.save
                WalletHistory.create(:user_id=>expired_transaction.user_id,:account_type=> "bonus account",:wallet_id=> wallet.id,:statement_date=> Time.zone.now,:transaction_type=>"bonus expiry",:amount=>unused,:action=>"debit",:balance=> wallet.bonus_balance)
              end#if wallet.save
            end
          end
        end
      end#expired_transactions.each do |expired_transaction|
    end#if expired_transactions.present?
    puts "[#{Time.current}] Bonus expiry check complete."
  end
end
