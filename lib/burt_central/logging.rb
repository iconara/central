module BurtCentral
  module Logging
    include Log4r

    PROJECT_ROOT_LOGGER_NAME = 'burt_central'

    def self.log_level=(level)
      Logger.root # this makes sure that the log level constants are set
      @@log_level = Log4r.const_get(level.to_s.upcase.to_sym)
    end

    def logger
      unless defined? @logger
        Logging.log_level = :info
        @logger = Logger.get(PROJECT_ROOT_LOGGER_NAME) rescue Logger.new(PROJECT_ROOT_LOGGER_NAME)
        @logger.outputters = Outputter.stderr
        @logger.level = @@log_level
      end
      @logger
    end

    def use_child_logger!(name)
      name = "#{logger.name}#{Log4rConfig::LoggerPathDelimiter}#{name}"
      @logger = Logger.get(name) rescue Logger.new(name)
    end
  end
end