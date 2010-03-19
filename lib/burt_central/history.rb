module BurtCentral
  class History
    include Logging
    include Utils

    # The events held by this instance. Populated either by {#load} or {#restore}
    # @return [Array<Event>] The events held by this instance.
    def events
      @events.dup
    end
    
    # Load events from the specified sources. The events will be merged and
    # sorted in historical order.
    #
    # @param [Array] sources A list of sources (objects responding to #events,
    #                        taking the time object passed as the :since option
    #                        to this method).
    # @param [Hash] options 
    # @option options [Time] :since (Time.today) Load events newer than this.
    # @return [Array<Event>] The loaded events (also available through {#events})
    def load(sources, options={})
      since = options[:since] || Time.today
      
      logger.info("Loading events since #{since}")
      
      @events = sources.inject([]) do |events, source|
        events += source.events(since)
        events
      end

      @events.sort!
      @events.reverse!
      @events
    end
    
    # Persist the history to a database collection. Events will be stored with
    # their URL as key.
    #
    # @param [Mongo::Collection] repository The collection to persist to.
    def persist(repository)
      logger.info("Persisting events")
      
      @events.each do |event|
        e = event.to_h
        e[:_id] = e.delete(:url)
        repository.save(e)
      end
    end
    
    # Restore the history from a database collection.
    #
    # @param [Mongo::Collection] repository The collection to restore from
    # @param [Hash] options 
    # @option options [Time] :since (Time.today) Restore all events newer than this time
    # @option options [Integer] :limit Restore this number of events, starting with the most recent
    # @return [Array<Event>] The restored events (also available through {#events})
    def restore(repository, options={})
      query = {:date => {'$gt' => options[:since] || Time.today}}
      
      query_opts = {:sort => [:date, :descending]}

      if options[:limit]
        query.delete(:date)
        query_opts[:limit] = options[:limit]
      end
      
      @events = repository.find(query, query_opts).map do |h|
        e = symbolize_keys(h)
        e[:url] = e.delete(:_id)
        Event.new(e)
      end
      
      logger.info("Restored #{@events.size} events")
      
      @events
    end
  end
end