module Central
  module Sources
    class Highrise
      include Logging
      
      def initialize(user_api, case_api)
        @user_api, @case_api = user_api, case_api
      end
      
      def events(since)
        logger.info('Loading Highrise users')

        users = @user_api.find(:all)
        users_by_id = users.inject({}) { |h, user| h[user.id] = user; h }

        logger.info('Loading Highrise cases')

        cases = @case_api.find(:all, :from => :open)

        logger.info('Loading Highrise notes')

        notes = cases.inject([]) do |notes, c|
          notes += c.notes(:since => since.strftime('%Y%m%d'))
          notes
        end

        host = @case_api.site.host
        
        notes.map do |note|
          Event.new(
            :title => note.subject_name,
            :date => note.updated_at,
            :instigator => users_by_id[note.author_id].name,
            :url => "https://#{host}/notes/#{note.id}",
            :type => :case_note
          )
        end
      rescue
        logger.warn("Could not load case notes: #{$!}")
        []
      end
    end
  end
end