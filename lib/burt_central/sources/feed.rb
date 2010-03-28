require 'feed-normalizer'
require 'open-uri'


module BurtCentral
  module Sources
    class Feed
      include Logging

      def initialize(url)
        @url = url
      end

      def events(since)
        logger.info('Loading feed')
        
        feed = FeedNormalizer::FeedNormalizer.parse(open(@url))
        
        events = feed.entries.select { |entry|
          entry.last_updated >= since
        }.map { |entry|
          Event.new(
            :id => entry.id,
            :title => entry.title,
            :date => entry.last_updated,
            :instigator => entry.authors.map { |a| a.strip }.join(', '),
            :url => entry.urls.first,
            :type => :blogpost
          )
        }
        
        logger.debug("Found #{events.size} entries")
        
        events
      rescue => e
        logger.warn("Could not load blog entries: #{e.message}")
        logger.debug(e.backtrace.join("\n"))
        []
      end
      
    end
  end
end