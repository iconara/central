$: << File.expand_path('../lib', __FILE__)

ENV['RACK_ENV'] ||= 'development'

if ENV['RACK_ENV'] == 'production'
  Bundler.setup(:default, :production)
else
  Bundler.setup(:default)
end

require 'app'

run App