require 'date'


module BurtCentral
  class History
    include Logging
    
    def initialize(configuration)
      @configuration = configuration
    end
    
    def events(since=Date.today)
      @configuration.set
      
      logger.info("Loading events since #{since}")
      
      sources.inject([]) { |events, source| events += source.new.events(since); events }.sort.reverse
    end
    
  private
  
    def sources
      [Sources::PivotalTracker, Sources::Github, Sources::Hoptoad, Sources::Highrise, Sources::Twitter]
    end
  end
end