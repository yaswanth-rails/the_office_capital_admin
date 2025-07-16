require 'faraday'
require 'faraday_middleware'

class FaradayRequest
  attr_reader :connection

  def initialize(url)
    @connection = Faraday.new(url) do |connection|
      connection.request  :url_encoded
      connection.adapter  Faraday.default_adapter
      connection.options[:timeout]      = 10
      connection.options[:open_timeout] = 10
    end
  end

  def get(path)
    connection.get(path)
  end
end
