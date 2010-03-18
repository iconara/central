require 'date'


module BurtCentral
  class History
    include Logging
    include Utils
    
    def initialize(configuration, sources)
      @configuration, @sources = configuration, sources
    end

    def events
      @events.dup
    end
    
    def load(since=Date.today)
      @configuration.set
      
      logger.info("Loading events since #{since}")
      
      @events = @sources.inject([]) do |events, source|
        events += source.new.events(since)
        events
      end

      @events.sort!
      @events.reverse!
      @events
    end
    
    def persist(repository)
      logger.info("Persisting events")
      
      @events.each do |event|
        repository.update({:url => event.url}, event.to_h, {:upsert => true})
      end
    end
    
    def restore(repository)
      @events = repository.find({}, {:sort => [:date, :descending]}).map do |h|
        Event.new(symbolize_keys(h))
      end
      
      logger.info("Restored #{@events.size} events")
      
      @events
    end
  end
end