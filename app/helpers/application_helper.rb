module ApplicationHelper

  def self.inr_format(amount,precision:2)
    integer_part, decimal_part = amount.to_s.split('.')
    integer_part = integer_part.to_s.gsub(/(\d)(?=(\d\d)+\d$)/, '\\1,')
    # Ensure correct decimal precision
    decimal_part = decimal_part.to_s.ljust(precision, "00") rescue "00"# Add trailing zeros if needed
    "#{integer_part}.#{decimal_part}"
  end

  def self.getLocationDetails(ip)
    begin
      res = Geocoder.search(ip)        
      return {country: res.first.country,city: res.first.city,state: res.first.state,country_code: ""}
    rescue Exception => e
      return {country: "",city: "",state: "",country_code: ""}
    end
  end#self.getLocationDetails(-)

  def onlineUsers
    online_users = User.where("last_response_at is not null and last_response_at > ? and last_response_at is NOT NULL  ",15.minutes.ago).count rescue 0
    if online_users == 0
      online_users = [10069,10304,15600,14204,14050,10520,15300,10503,13704].sample
    else
      multiply=[5122,5132,5143,5154,5164].sample
      online_users=online_users*multiply
    end
    return online_users
  end#onlineUsers

  def resource_name
    :user
  end

  def resource_class
    User
  end

  def resource
    @resource ||= User.new
  end#resource

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end#devise_mapping

end

