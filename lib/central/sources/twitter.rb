module Central
  module Sources
    class Twitter
      include Logging
   
      def initialize(api, user, list)
        @api, @user, @list = api, user, list
      end

      def events(since)
        logger.info("Loading tweets from #{@user}/#{@list}")
        
        events = []
        page = 1
        
        catch(:all_found) do
          loop do
            logger.debug("Loading page #{page}")
          
            begin
              tweets = @api.list_timeline(@user, @list, :page => page)
              
              logger.debug("Found #{tweets.size} tweets")
            rescue
              logger.warn("Error while listing timeline #{$!.message}")
              tweets = []
            end
            
            throw :all_found if tweets.empty?
        
            tweets.each do |tweet|
              throw :all_found unless Time.parse(tweet.created_at) >= since
              
              url = "http://twitter.com/#{tweet.user.screen_name}/status/#{tweet.id}"
              
              events << Event.new(
                :title => tweet.text,
                :date => Time.parse(tweet.created_at),
                :instigator => tweet.user.name,
                :url => url,
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