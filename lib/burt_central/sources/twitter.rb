require 'date'
require 'twitter'


module BurtCentral
  module Sources
    class Twitter
      include Logging
   
      def events(since)
        logger.info('Loading tweets')
        
        events = []
        page = 1
        
        catch(:all_found) do
          loop do
            logger.debug("Loading page #{page}")
          
            tweets = ::Twitter.list_timeline('burtcorp', 'meet-the-burts', :page => page)
        
            tweets.each do |tweet|
              throw :all_found unless Date.parse(tweet.created_at) >= since
              
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