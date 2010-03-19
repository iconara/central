module BurtCentral
  class History
    include Logging
    include Utils
    
    def initialize(configuration, sources=[])
      @configuration, @sources = configuration, sources
    end

    def events
      @events.dup
    end
    
    def load(since=Time.today)
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
        e = event.to_h
        e[:_id] = e.delete(:url)
        repository.save(e)
      end
    end
    
    def restore(repository, since=Time.today)
      @events = repository.find({:date => {'$gt' => since.getutc}}, {:sort => [:date, :descending]}).map do |h|
        e = symbolize_keys(h)
        e[:url] = e.delete(:_id)
        Event.new(e)
      end
      
      logger.info("Restored #{@events.size} events")
      
      @events
    end
  end
end