class CitiesController < ApplicationController
  def index 
    # @cities = CS.get(params[:country], params[:state])
    @cities = JSON.parse(File.read("#{Rails.root}/public/city.json")) rescue []

    if @cities.present?
      @cities = @cities.select{|state| state["countryCode"] == params[:country] and state["stateCode"] == params[:state]} rescue []
    end
  end#index
end
