Sidekiq.configure_server do |config|
  config.redis = { :url => "redis://#{}localhost:6380/0", password: ENV["REDIS_PWD"]}
end

Sidekiq.configure_client do |config|
  config.redis = { :url => "redis://#{}localhost:6380/0", password: ENV["REDIS_PWD"]}
end
