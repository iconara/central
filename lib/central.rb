autoload :Hoptoad, 'hoptoad/error'
autoload :Highrise, 'highrise/highrise'

module PivotalTracker
  autoload :Story, 'pivotal_tracker/story'
  autoload :Activity, 'pivotal_tracker/activity'
end

module Central
  autoload :Configuration, 'central/configuration'
  autoload :Event, 'central/event'
  autoload :History, 'central/history'
  autoload :Logging, 'central/logging'
  autoload :Utils, 'central/utils'
  
  module Sources
    autoload :PivotalTracker, 'central/sources/pivotal_tracker'
    autoload :Highrise, 'central/sources/highrise'
    autoload :Hoptoad, 'central/sources/hoptoad'
    autoload :Github, 'central/sources/github'
    autoload :Twitter, 'central/sources/twitter'
    autoload :Feed, 'central/sources/feed'
  end
end