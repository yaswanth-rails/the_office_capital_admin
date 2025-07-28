class ExternalGuest < ApplicationRecord
  include Current
  attr_accessor :current_toc
  has_paper_trail on: [:update, :destroy], ignore: [:track_changes,:updated_at], if: Proc.new { Current.toc }
  belongs_to :group
  has_many :bookings

  validates :name, :email, :mobile_number, presence: true
  validates_uniqueness_of :email, :mobile_number
end
