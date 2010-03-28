require 'yaml'
require 'twitter'


module BurtCentral
  class Configuration
    include Utils
    include Logging
    
    def initialize(conf, environment=:development)
      @configuration = symbolize_keys(conf)
      @environment = environment.to_sym

      configure_logging
    end
    
    def self.load(path, environment=:development)
      Configuration.new(YAML::load(open(path)), environment)
    end

    def sources
      sources = []
      sources << github_source
      sources << hoptoad_source
      sources << highrise_source
      sources << twitter_source
      sources += pivotal_tracker_sources
      sources += feed_sources
      sources
    end
    
    def events_collection
      raise 'No database name specified!' unless @configuration.has_key?(:database)

      configure_database

      @db[:events_collection]
    end
    
    def password
      @configuration[:password]
    end
  
  private
  
    def configure_database
      unless defined? @db
        base_name = @configuration[:database]
        database_name = "#{base_name}_#{@environment}"

        logger.info("Using database \"#{database_name}\"")
        
        mongo_logger = @environment == :test ? nil : logger
        
        @db = {}
        @db[:connection] = Mongo::Connection.new(nil, nil, :logger => mongo_logger)
        @db[:dabatase] = @db[:connection].db(database_name)
        @db[:events_collection] = @db[:dabatase].collection('events')
      end
    end
  
    def configure_logging
      level = @configuration[:log_level] || 'INFO'
      
      Logging.send(:define_method, :default_log_level) { level }
    end

    def github_source
      if @configuration.has_key?(:github)
        login = @configuration[:github][:login]
        token = @configuration[:github][:token]
        
        raise 'GitHub configuration is missing login' unless login
        raise 'GitHub configuration is missing token' unless token
      
        BurtCentral::Sources::Github.new(login, token)
      else
        logger.warn('No GitHub configuration found')
      end
    rescue => e
      logger.warn("Error while configuring the GitHub source: \"#{e.message}\"")
      logger.debug(e.backtrace.join("\n"))
    end
    
    def hoptoad_source
      if @configuration.has_key?(:hoptoad)
        account = @configuration[:hoptoad][:account]
        token   = @configuration[:hoptoad][:token]

        raise 'Hoptoad configuration missing account' unless account
        raise 'Hoptoad configuration missing token'   unless token

        Hoptoad::Error.site = "http://#{account}.hoptoadapp.com"
        Hoptoad::Error.auth_token = token

        BurtCentral::Sources::Hoptoad.new(Hoptoad::Error)
      else
        logger.warn('No Hoptoad configuration found')
      end
    rescue => e
      logger.warn("Error while configuring the Hoptoad source: \"#{e.message}\"")
      logger.debug(e.backtrace.join("\n"))
    end
    
    def highrise_source
      if @configuration.has_key?(:highrise)
        account = @configuration[:highrise][:account]
        token   = @configuration[:highrise][:token]
        
        raise 'Highrise configuration missing account' unless account
        raise 'Highrise configuration missing token'   unless token
      
        Highrise::Base.site = "https://#{token}:X@#{account}.highrisehq.com/"
      
        BurtCentral::Sources::Highrise.new(Highrise::User, Highrise::Kase)
      else
        logger.warn('No Highrise configuration found')
      end
    rescue => e
      logger.warn("Error while configuring the Highrise source: \"#{e.message}\"")
      logger.debug(e.backtrace.join("\n"))
    end
    
    def twitter_source
      if @configuration.has_key?(:twitter)
        user = @configuration[:twitter][:user]
        list = @configuration[:twitter][:list]
        
        raise 'Twitter configuration missing user' unless user
        raise 'Twitter configuration missing list' unless list
      
        twitter = Twitter::Base.new(Twitter::HTTPAuth.new('', ''))
      
        BurtCentral::Sources::Twitter.new(twitter, user, list)
      else
        logger.warn('No Twitter configuration found')
      end
    rescue => e
      logger.warn("Error while configuring the Twitter source: \"#{e.message}\"")
      logger.debug(e.backtrace.join("\n"))
    end
    
    def pivotal_tracker_sources
      if @configuration.has_key?(:pivotal_tracker)
        projects = @configuration[:pivotal_tracker][:projects]
        token    = @configuration[:pivotal_tracker][:token]

        raise 'Pivotal Tracker configuration missing projects' unless projects && projects.size > 0
        raise 'Pivotal Tracker configuration missing token'    unless token

        PivotalTracker::Story.site = 'http://www.pivotaltracker.com/services/v3/projects/:project_id'
        PivotalTracker::Story.headers['X-TrackerToken'] = token
        PivotalTracker::Activity.site = 'http://www.pivotaltracker.com/services/v3/projects/:project_id'
        PivotalTracker::Activity.headers['X-TrackerToken'] = token
      
        projects.map do |project|
          BurtCentral::Sources::PivotalTracker.new(PivotalTracker::Activity, project)
        end
      else
        logger.warn('No Pivotal Tracker configuration found')
      end
    rescue => e
      logger.warn("Error while configuring the Pivotal Tracker source: \"#{e.message}\"")
      logger.debug(e.backtrace.join("\n"))
    end
    
    def feed_sources
      if @configuration.has_key?(:feeds)
        feeds = @configuration[:feeds]
        
        raise 'Feeds configuration is missing feeds' unless feeds && feeds.size > 0
        
        feeds.map do |feed_url|
          BurtCentral::Sources::Feed.new(feed_url)
        end
      else
        logger.warn('No feed configuration found')
      end
    rescue => e
      logger.warn("Error while configuring the feed source: \"#{e.message}\"")
      logger.debug(e.backtrace.join("\n"))
    end
  end
end