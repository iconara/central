module Central
  module Sources
    class PivotalTracker
      include Logging

      DESCRIPTION_PATTERN = /^([\w\s]+):? "?(.+?)"?$/m
      
      ACTIVITY_TYPES = {
        'added'          => :add,
        'delivered'      => :completion,
        'added comment'  => :comment,
        'edited'         => :edit,
        'accepted'       => :accept,
        'rejected'       => :rejection,
        'deleted'        => :deletion,
        # 'started'       => :start,
        # 'finished'      => :finish,
        # 'attached file' => :upload,
        # 'moved'         => :move,
        # 
        # 'estimated'     => :estimation,
        # 'restarted'     => :restart,
      }
      
      def initialize(api, project)
        @api, @project = api, project
      end
      
      def events(since)
        logger.info("Loading Pivotal Tracker activity for project #{@project}")

        activities = @api.find(:all, :params => {
          :project_id => @project,
          :occurred_since_date => since.strftime('%d %b %Y'),
          :limit => 100
        })
        
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
                :url => "http://www.pivotaltracker.com/story/show/#{activity.stories.story.id}",
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