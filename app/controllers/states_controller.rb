class StatesController < ApplicationController
	protect_from_forgery except: :index
  def index
    @states = JSON.parse(File.read("#{Rails.root}/public/state.json")) rescue []

    if @states.present?
      @states = @states.select{|state| state["countryCode"] == params[:country] } rescue []
    end
  end#index
end
