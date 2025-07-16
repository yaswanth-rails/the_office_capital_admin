class ExternalGuest < ApplicationRecord
  belongs_to :group
  has_many :bookings

  validates :name, :email, :mobile_number, presence: true
  validates_uniqueness_of :email, :mobile_number
end
