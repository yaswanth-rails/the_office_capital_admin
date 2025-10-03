class ManagedOfficeRequirement < ApplicationRecord
  include Current
  attr_accessor :current_toc  
  has_paper_trail on: [:update, :destroy], ignore: [:updated_at], if: Proc.new { Current.toc }
  validates :facade_type, inclusion: { in: %w[non_facade single double triple] }
  belongs_to :user
  rails_admin do
    list do
      field :id
      field :user
      field :plan
      field :facade_type
      field :reference_number
      field :ceo_cabins
      field :ceo_cabin_seaters
      field :manager_cabins
      field :manager_cabin_seaters
      field :conference_rooms
      field :conference_room_seaters
      field :employee_seats
      field :created_at
      field :updated_at
    end
  end
end
