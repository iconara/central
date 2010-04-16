require 'json'
require 'base64'
require 'app'


module HttpAuthHelpers
  def http_credentials(username, password)
    {'HTTP_AUTHORIZATION' => 'Basic ' + Base64.encode64("#{username}:#{password}")}
  end
end

Spec::Runner.configure do |config|
  config.before(:all) do
    @configuration = Central::Configuration.load(ENV['CONFIGURATION_PATH'], :test)
    @events_collection = @configuration.events_collection
  end
    
  config.before(:each) do
    @events_collection.remove
  end
  
  config.include(HttpAuthHelpers)
end