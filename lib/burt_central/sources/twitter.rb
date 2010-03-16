require 'twitter'


module BurtCentral
  module Sources
    class Twitter
      include Logging
   
      def events(since)
        logger.info('Loading tweets')
        
        tweets = ::Twitter.list_timeline('burtcorp', 'meet-the-burts')
        tweets.map do |tweet|
          Event.new(
            :title => tweet.text,
            :date => Time.parse(tweet.created_at),
            :instigator => tweet.user.name,
            :url => "http://twitter.com/#{tweet.user.screen_name}/status/#{tweet.id}",
            :type => :tweet
          )
        end
      end
    end
  end
end