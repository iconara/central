autoload :Hoptoad, 'hoptoad/error'
autoload :PivotalTracker, 'pivotal_tracker/story'
autoload :Highrise, 'highrise/highrise'

module BurtCentral
  autoload :Configuration, 'burt_central/configuration'
  autoload :Event, 'burt_central/event'
  autoload :History, 'burt_central/history'
  autoload :Logging, 'burt_central/logging'
  
  module Sources
    autoload :PivotalTracker, 'burt_central/sources/pivotal_tracker'
    autoload :Highrise, 'burt_central/sources/highrise'
    autoload :Hoptoad, 'burt_central/sources/hoptoad'
    autoload :Github, 'burt_central/sources/github'
  end
end