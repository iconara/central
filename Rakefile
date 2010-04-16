$: << File.expand_path('../lib', __FILE__)

ENV['CENTRAL_ENV'] ||= 'development'

if ENV['CENTRAL_ENV'] == 'production'
  Bundler.setup(:default, :production)
else
  Bundler.setup(:default, :development, :testing)
end

require 'mongo'
require 'central'


task :default => :events

task :setup do
  configuration_path = File.expand_path('../config/common.yml', __FILE__)
  
  $configuration = Central::Configuration.load(configuration_path, ENV['CENTRAL_ENV'].to_sym)
  $history = Central::History.new
end

task :events => :setup do
  $history.restore($configuration.events_collection, :since => Time.yesterday)
  $history.events.each do |event|
    puts '%s %6s %20s: %-40s %s' % [
      event.date.strftime('%Y-%m-%d'),
      event.type,
      event.instigator,
      event.title,
      event.url
    ]
  end    
end

task :cache => :setup do
  #default_since = Time.local(2000, 1, 1)
  default_since = Time.now - (24 * 60 * 60 * 4)
  
  newest_item = $configuration.events_collection.find_one({}, {:fields => [:date], :sort => [:date, :descending]}) || {'date' => default_since}

  $history.load($configuration.sources, :since => newest_item['date'])
  $history.persist($configuration.events_collection)
end

begin
  require 'spec/rake/spectask'

  Spec::Rake::SpecTask.new(:spec) do |spec|
    spec.spec_opts << '--options' << 'spec/spec.opts'
    spec.spec_files = FileList['spec/**/*_spec.rb'].exclude('spec/app_spec.rb')
  end

  Spec::Rake::SpecTask.new(:rcov) do |spec|
    spec.spec_opts << '--options' << 'spec/spec.opts'
    spec.spec_files = FileList['spec/**/*_spec.rb'].exclude('spec/app_spec.rb')
    spec.rcov = true
  end

  Spec::Rake::SpecTask.new(:webspec) do |spec|
    spec.spec_opts << '--options' << 'spec/spec.opts'
    spec.spec_files = FileList['spec/app/**/*_spec.rb']
  end
rescue => e
  puts e.class
end

begin
  require 'yard'

  YARD::Rake::YardocTask.new do |t|
    t.files   = ['lib/**/*.rb']
    t.options = []
  end
rescue
  
end