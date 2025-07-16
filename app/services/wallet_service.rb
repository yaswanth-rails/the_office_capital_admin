class WalletService
  def self.refund!(user:, amount:, bonus_amount: 0.0, booking_group: nil, booking: nil,transaction_type:)
    return if amount <= 0
    wallet = user.company.wallets.first
    master_wallet = Wallet.find(ENV["TOC_MASTER_WALLET"])
    remaining_bonus = bonus_amount

    booking_id = booking&.id
    booking_group_id = booking_group&.id
    if booking_group.present?
      ref_no = booking_group.bookings.first.reference_number
    elsif booking.present?
      ref_no = booking.reference_number
    end

    if bonus_amount > 0
      remaining_bonus = refund_bonus(user: user, booking_group_id: booking_group_id, amount: bonus_amount,wallet: wallet, booking_id: booking_id,transaction_type: transaction_type,ref_no: ref_no)
    end
    normal_amount = amount - bonus_amount
    if normal_amount > 0
      wallet.with_lock do
        wallet.balance = wallet.balance + normal_amount
        master_wallet.balance = master_wallet.balance - normal_amount
        if wallet.save
          WalletHistory.create(wallet_id: wallet.id,user_id: user.id,booking_id: booking_id,booking_group_id: booking_group_id,account_type: "inr account",transaction_type: transaction_type,action: "credit",amount: normal_amount,reference_number: ref_no,balance: wallet.balance,statement_date: Time.zone.now)
          if master_wallet.save
            WalletHistory.create(wallet_id: master_wallet.id,booking_id: booking_id,booking_group_id: booking_group_id,account_type: "inr account",transaction_type: transaction_type,action: "debit",amount: normal_amount,reference_number: ref_no,balance: master_wallet.balance,statement_date: Time.zone.now)
          end
        end#if wallet.save
      end#wallet.with_lock do
    end
    remaining_bonus
  end

  def self.refund_bonus(user:, booking_group_id:, amount:, wallet:, booking_id:, transaction_type:, ref_no:)
    remaining = amount
    used_entries = wallet.wallet_histories.used_entries

    used_entries.each do |entry|
      break if remaining <= 0

      refundable = [entry.used_amount, remaining].min

      if entry.update!(used_amount: entry.used_amount - refundable)
        wallet.with_lock do
          wallet.bonus_balance = wallet.bonus_balance + refundable
          if wallet.save
            WalletHistory.create(wallet_id: wallet.id,user_id: user.id,booking_id: booking_id,booking_group_id: booking_group_id,account_type: "bonus account",transaction_type: transaction_type,action: "credit",amount: refundable,reference_number: ref_no,balance: wallet.bonus_balance,statement_date: Time.zone.now)
          end
        end#wallet.with_lock do
      end
      remaining -= refundable
    end#used_entries.each do |entry|
    remaining
  end#refund_bonus
end
