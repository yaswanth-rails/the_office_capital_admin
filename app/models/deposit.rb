class Deposit < ApplicationRecord
  include Current
  attr_accessor :current_toc
  has_paper_trail on: [:update, :destroy], ignore: [:track_changes,:updated_at], if: Proc.new { Current.toc }
	has_many :wallet_histories
	belongs_to :user, optional: true
  rails_admin do
    list do
    	field :id
      field :user
      field :reference_number
      field :status
      field :payment_id
      field :created_at
      field :updated_at
    end
  end
end
