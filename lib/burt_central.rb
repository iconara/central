require 'ext/time'


autoload :Hoptoad, 'hoptoad/error'
autoload :Highrise, 'highrise/highrise'

module PivotalTracker
  autoload :Story, 'pivotal_tracker/story'
  autoload :Activity, 'pivotal_tracker/activity'
end

module BurtCentral
  autoload :Configuration, 'burt_central/configuration'
  autoload :Event, 'burt_central/event'
  autoload :History, 'burt_central/history'
  autoload :Logging, 'burt_central/logging'
  autoload :Utils, 'burt_central/utils'
  
  module Sources
    autoload :PivotalTracker, 'burt_central/sources/pivotal_tracker'
    autoload :Highrise, 'burt_central/sources/highrise'
    autoload :Hoptoad, 'burt_central/sources/hoptoad'
    autoload :Github, 'burt_central/sources/github'
    autoload :Twitter, 'burt_central/sources/twitter'
  end
end