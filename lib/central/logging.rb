require 'log4r'


module Central
  module Logging
    def logger
      unless defined? @logger
        begin
          @logger = Log4r::Logger.get('central')
        rescue 
          @logger = Log4r::Logger.new('central')
          @logger.add(Log4r::Outputter.stdout)
          @logger.level = a2level(default_log_level)
        end
      end
      @logger
    end
    
    def default_log_level
      :info
    end
    
  private
  
    def a2level(str)
      Log4r::Log4rConfig::LogLevels.index(str.to_s.upcase) + 1
    end
  end
end