module BurtCentral
  module Sources
    class PivotalTracker
      include Logging

      DESCRIPTION_PATTERN = /^([\w\s]+):? "?(.+?)"?$/m
      
      ACTIVITY_TYPES = {
        'finished'      => :completion,
        'added comment' => :note,
        'edited'        => :edit,
        'accepted'      => :accept,
        # 'started'       => :start,
        # 'delivered'     => :deliver,
        # 'attached file' => :upload,
        # 'moved'         => :move,
        # 'deleted'       => :delete,
        # 'estimated'     => :estimation,
        # 'restarted'     => :restart,
      }
      
      def events(since)
        logger.info('Loading Pivotal Tracker stories')

        activities = ::PivotalTracker::Activity.find(:all, :params => {
          :project_id => '19935',
          :occurred_since_date => since.strftime('%d %b %Y'),
          :limit => 100
        })
        
        #<PivotalTracker::Activity:0x103a84388 @attributes={"author"=>"Gustav von Sydow", "occurred_at"=>Mon Mar 22 16:42:24 UTC 2010, "id"=>15142937, "version"=>10411, "description"=>"Gustav von Sydow edited \"Update framework and processes for idea-code-learn feedback loop\"", "event_type"=>"story_update", "stories"=>#<PivotalTracker::Activity::Stories:0x103a7cfc0 @attributes={"story"=>#<PivotalTracker::Story:0x103a7bc60 @attributes={"name"=>"Update framework and processes for idea-code-learn feedback loop", "url"=>"http://www.pivotaltracker.com/services/v3/projects/19935/stories/2862565", "id"=>2862565}, @prefix_options={}>}, @prefix_options={}>}, @prefix_options={:project_id=>"19935"}>

        events = activities.map do |activity|
          description = activity.description.sub(activity.author, '').strip
          
          if description =~ DESCRIPTION_PATTERN
            action = $1
            title = $2
            
            if ACTIVITY_TYPES.has_key?(action)
              Event.new(
                :id => "http://www.pivotaltracker.com/services/v3/projects/19935/activities/#{activity.id}",
                :title => title,
                :date => activity.occurred_at,
                :instigator => activity.author,
                :url => activity.stories.story.url,
                :type => ACTIVITY_TYPES[action]
              )
            else
              nil
            end
          else
            logger.warn("Activity description did not match pattern: \"#{description}\"")
            
            nil
          end
        end
        events.compact
      rescue
        logger.warn("Could not load stories: #{$!}")
        []
      end
    end
  end
end