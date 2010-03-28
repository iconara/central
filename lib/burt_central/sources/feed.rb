require 'atom'


module BurtCentral
  module Sources
    class Feed
      include Logging

      def initialize(url, feed_loader=Atom::Feed)
        @url = url
        @feed_loader = feed_loader
      end

      def events(since)
        logger.info('Loading feed')
        
        #<Atom::Entry:0x1012cdf88 @id="http://blog.burtcorp.com/?p=118", @content="<p><a href=\"http://www.cdixon.org/\">Chris Dixon&#8217;s blog</a> has lately emerged as one of the best blogs we read. Lately Chris&#8217; posts has been a lot about early stage funding &#8211; something we think a lot about...", @links=[<Atom::Link href:'http://blog.burtcorp.com/2009/09/29/enabling-the-new-business-models/' type:'text/html'>, <Atom::Link href:'http://blog.burtcorp.com/2009/09/29/enabling-the-new-business-models/#comments' type:'text/html'>, <Atom::Link href:'http://blog.burtcorp.com/2009/09/29/enabling-the-new-business-models/feed/atom/' type:'application/atom+xml'>], @summary="Chris Dixon&#8217;s blog has lately emerged as one of the best blogs we read. Lately Chris&#8217; posts has been a lot about early stage funding &#8211; something we think a lot about. More recently Chris has been talking about business models, and more specifically advertising based business models.\nThis post discusses that advertising money is spent [...]", @published=Tue Sep 29 13:16:19 UTC 2009, @title="Enabling the new Business Models", @simple_extensions={"{http://purl.org/syndication/thread/1.0,total}"=>["3"]}, @authors=[<Atom::Person name:'john' uri:'http://www.burtcorp.com' email:'], @categories=[#<Atom::Category:0x1012c11e8 @scheme="http://blog.burtcorp.com", @term="Uncategorized">, #<Atom::Category:0x1012bc3f0 @scheme="http://blog.burtcorp.com", @term="advertising">, #<Atom::Category:0x1012b7710 @scheme="http://blog.burtcorp.com", @term="business model">, #<Atom::Category:0x1012b6c48 @scheme="http://blog.burtcorp.com", @term="chris dixon">, #<Atom::Category:0x1012b5ca8 @scheme="http://blog.burtcorp.com", @term="money">, #<Atom::Category:0x1012b4b00 @scheme="http://blog.burtcorp.com", @term="rich">], @updated=Tue Sep 29 13:31:18 UTC 2009, @contributors=[]>        
        
        events = []
        
        feed = @feed_loader.load_feed(URI.parse(@url))
        feed.each_entry(:since => since, :paginate => true) do |entry|
          events << Event.new(
            :id => entry.id,
            :title => entry.title,
            :date => entry.updated,
            :instigator => entry.authors.map { |a| a.name }.join(', '),
            :url => entry.links.self.to_s,
            :type => :blogpost
          )
        end
        
        logger.debug("Found #{events.size} entries")
        
        events
      rescue => e
        logger.warn("Could not load blog entries: #{e.message}")
        logger.debug(e.backtrace.join("\n"))
        []
      end
      
    end
  end
end