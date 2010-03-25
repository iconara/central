require 'twitter'


module BurtCentral
  module Sources
    class Twitter
      include Logging
   
      def initialize(user, list)
        @user, @list = user, list
      end

      def events(since)
        logger.info("Loading tweets from #{@user}/#{@list}")
        
        twitter = ::Twitter::Base.new(::Twitter::HTTPAuth.new('', ''))
        
        events = []
        page = 1
        
        catch(:all_found) do
          loop do
            logger.debug("Loading page #{page}")
          
            begin
              tweets = twitter.list_timeline(@user, @list, :page => page)
            rescue
              logger.warn("Error while listing timeline #{$!.message}")
              tweets = []
            end
            
            throw :all_found if tweets.empty?
        
            tweets.each do |tweet|
              throw :all_found unless Time.parse(tweet.created_at) >= since
              
              events << Event.new(
                :title => tweet.text,
                :date => Time.parse(tweet.created_at),
                :instigator => tweet.user.name,
                :url => "http://twitter.com/#{tweet.user.screen_name}/status/#{tweet.id}",
                :type => :tweet
              )
            end
        
            page += 1
          end
        end
        
        events
      end
    end
  end
end