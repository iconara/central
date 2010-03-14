require 'yaml'


module BurtCentral
  class Configuration
    def initialize(conf)
      @configuration = symbolize_keys(conf)

      check_config
    end
    
    def self.load(path)
      Configuration.new(YAML::load(open(path)))
    end

    # Configures all services. Most things that are configured are global (e.g.
    # ActiveResource models), so running this has quite extensive side effects.
    def set
      configure_logging(@configuration[:log_level])
      configure_hoptoad(@configuration[:hoptoad])
      configure_pivotal_tracker(@configuration[:pivotal_tracker])
      configure_github(@configuration[:github])
      configure_highrise(@configuration[:highrise])
    end
  
  private
  
    def check_config
      raise 'Configuration is nil!' if @configuration.nil?

      required_keys = [:hoptoad, :pivotal_tracker, :github, :highrise]
      missing_keys = required_keys.reject { |k| @configuration.has_key?(k) }
      
      raise "Missing configuration keys: #{missing_keys.join(', ')}" unless missing_keys.empty?
      raise 'Hoptoad configuration missing or incomplete' unless @configuration[:hoptoad].has_key?(:token)
      raise 'Pivotal Tracker configuration missing or incomplete' unless @configuration[:pivotal_tracker].has_key?(:token)
      raise 'GitHub configuration missing or incomplete' unless @configuration[:github].has_key?(:user) && @configuration[:github].has_key?(:token)
      raise 'Highrise configuration missing or incomplete' unless @configuration[:highrise].has_key?(:token)
    end

    # Recursively changes all keys to symbols
    def symbolize_keys(conf)
      return conf unless conf.is_a?(Hash)
      conf.keys.inject({}) do |c, k|
        c[k.to_sym] = symbolize_keys(conf[k])
        c
      end
    end
  
    def configure_logging(log_level)
      Logging.send(:define_method, :default_log_level) do
        log_level
      end
    end

    def configure_hoptoad(conf)
      Hoptoad::Error.site = 'http://burt.hoptoadapp.com'
      Hoptoad::Error.auth_token = conf[:token]
    end
  
    def configure_pivotal_tracker(conf)
      PivotalTracker::Story.site = 'http://www.pivotaltracker.com/services/v3/projects/:project_id'
      PivotalTracker::Story.headers['X-TrackerToken'] = conf[:token]
    end
  
    def configure_github(conf)
      Octopi::Api.api = Octopi::AuthApi.instance
      Octopi::Api.api.login = conf[:user]
      Octopi::Api.api.token = conf[:token]
      APICache.logger.level = Logger::FATAL
    end
  
    def configure_highrise(conf)
      Highrise::Base.site = "https://#{conf[:token]}:X@burt.highrisehq.com/"
    end
  end
end