module BurtCentral
  def self.configure(conf)
    conf = symbolize_keys(conf)
    
    raise 'Configuration is nil!' if conf.nil?
    missing_keys = [:hoptoad, :pivotal_tracker, :github, :highrise].reject { |k| conf.has_key?(k) }
    raise "Missing configuration keys: #{missing_keys.join(', ')}" unless missing_keys.empty?

    configure_logging(conf[:log_level])
    configure_hoptoad(conf[:hoptoad])
    configure_pivotal_tracker(conf[:pivotal_tracker])
    configure_github(conf[:github])
    configure_highrise(conf[:highrise])
  end
  
private

  # Recursively changes all keys to symbols
  def self.symbolize_keys(conf)
    return conf unless conf.is_a?(Hash)
    conf.keys.inject({}) do |c, k|
      c[k.to_sym] = symbolize_keys(conf[k])
      c
    end
  end
  
  def self.configure_logging(log_level)
    Logging.log_level = log_level if log_level
  end

  def self.configure_hoptoad(conf)
    raise 'Hoptoad configuration missing or incomplete' unless conf.has_key?(:token)
    Hoptoad::Error.site = 'http://burt.hoptoadapp.com'
    Hoptoad::Error.auth_token = conf[:token]
  end
  
  def self.configure_pivotal_tracker(conf)
    raise 'Pivotal Tracker configuration missing or incomplete' unless conf.has_key?(:token)
    PivotalTracker::Story.site = 'http://www.pivotaltracker.com/services/v3/projects/:project_id'
    PivotalTracker::Story.headers['X-TrackerToken'] = conf[:token]
  end
  
  def self.configure_github(conf)
    raise 'GitHub configuration missing or incomplete' unless conf.has_key?(:user) && conf.has_key?(:token)
    Octopi::Api.api = Octopi::AuthApi.instance
    Octopi::Api.api.login = conf[:user]
    Octopi::Api.api.token = conf[:token]
    APICache.logger.level = Logger::FATAL
  end
  
  def self.configure_highrise(conf)
    raise 'Highrise configuration missing or incomplete' unless conf.has_key?(:token)
    Highrise::Base.site = "https://#{conf[:token]}:X@burt.highrisehq.com/"
  end
end