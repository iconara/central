module BurtCentral
  module Sources
    class PivotalTracker
      include Logging
      
      def events(since)
        logger.info('Loading Pivotal Tracker stories')

        since_str = since.strftime('%d %b %Y')

        stories = ::PivotalTracker::Story.find(:all, :params => {
          :project_id => '19935',
          :filter => "modified_since:\"#{since_str}\""
        })

        #<PivotalTracker::Story:0x1050bca10 @prefix_options={:project_id=>"19935"}, @attributes={"name"=>"Ad table has blank ad names. Should be (unknown) as for unknown site names.", "current_state"=>"started", "requested_by"=>"Daniel Gaiottino", "created_at"=>Sat Mar 13 11:21:27 UTC 2010, "updated_at"=>Sat Mar 13 11:21:28 UTC 2010, "url"=>"http://www.pivotaltracker.com/story/show/2781202", "id"=>2781202, "story_type"=>"bug", "description"=>nil, "owned_by"=>"Daniel Gaiottino"}>

        stories.map do |story|
          if story.respond_to? :owned_by
            instigator = story.owned_by
          else
            instigator = story.requested_by
          end
          
          type = case story.story_type
                 when 'bug' then :bug
                 when 'chore' then :todo
                 when 'feature' then :feature
                 when 'release' then :release
                 else :feature
                 end

          Event.new(
            :title => story.name,
            :date => story.updated_at,
            :instigator => instigator,
            :url => story.url,
            :type => type
          )
        end
      rescue
        logger.warn("Could not load stories: #{$!}")
        []
      end
    end
  end
end