class EmployeeKycStat < ApplicationRecord
  include Current
  attr_accessor :current_toc
  has_paper_trail on: [:update, :destroy], ignore: [:track_changes,:updated_at], if: Proc.new { Current.toc }
	rails_admin do      
		list do
			field :id 
			field :toc_id
			field :user_id
			include_all_fields
		end
	end
end
