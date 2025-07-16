class ContactSubmission < ApplicationRecord
  include Current
  attr_accessor :current_toc
  validates_presence_of :firstname
  validates_presence_of :lastname
  validates_presence_of :email
  validates_presence_of :phone
  validates_presence_of :message
  validates_format_of :message, :with=> /\A[a-zA-Z0-9"!:.,()\[\] ]*\z/, :message => 'allowed special characters are "!:.,()[]'
  ## mobile number validation
  validates_format_of :phone, with: /\A[0-9]*$\z/, message: "number is invalid"
  
  ## email format validation
  validates_format_of :email, with:  /\A(\S+)@(.+)\.(\S+)\z/
  rails_admin do
    list do
      field :firstname
      field :lastname
      field :email
      field :phone
      field :message
    end
  end
end
