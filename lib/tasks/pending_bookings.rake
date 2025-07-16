namespace :pending_bookings do
  desc "Destroy booking status in pending for long time"
  task clean: :environment do
    puts "[#{Time.current}] Starting bonus expiry check..."
    pending_bookings = BookingGroup.where(status: "pending").where("created_at < ?", 40.minutes.ago)
    if pending_bookings.present?
      pending_bookings.each do |pending_booking|
        puts "#{pending_booking.id} #{pending_booking.bookings.first.reference_number} Destroyed"
        pending_booking.destroy
      end
    end#if expired_transactions.present?
    puts "[#{Time.current}] pending bookings destroy complete."
  end
end
