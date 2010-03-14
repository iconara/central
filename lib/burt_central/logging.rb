require 'log4r'


module BurtCentral
  module Logging
    def logger
      unless defined? @logger
        @logger = Log4r::Logger.get('burt_central') rescue Log4r::Logger.new('burt_central')
        @logger.outputters = Log4r::Outputter.stderr
        @logger.level = a2level(default_log_level)
      end
      @logger
    end
    
    def default_log_level
      :info
    end
    
  private
  
    def a2level(str)
      Log4r::Log4rConfig::LogLevels.index(str.to_s.upcase)
    end
  end
end