module Central
  module Sources
    class Hoptoad
      include Logging
      
      def initialize(api)
        @api = api
      end
      
      def events(since)
        logger.info('Loading Hoptoad errors')

        errors = @api.find(:all)

        logger.debug("Found #{errors.size} errors")

        host = @api.site.host

        errors.select { |error|
          error.most_recent_notice_at >= since && error.rails_env == 'production'
        }.map { |error|
          Event.new(
            :title => error.error_message,
            :date => error.most_recent_notice_at,
            :instigator => nil,
            :url => "http://#{host}/errors/#{error.id}",
            :type => :error
          )
        }
      rescue
        logger.warn("Could not load errors: #{$!}")
        []
      end
      
    end
  end
end