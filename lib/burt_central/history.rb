module BurtCentral
  class History
    include Logging
    
    def initialize(configuration)
      @configuration = configuration
    end
    
    def events(since=Date.today)
      @configuration.set
      
      logger.info("Loading events since #{since}")
      
      events = stories(since) + commits(since) + errors(since) + case_notes(since)
      events.sort.reverse
    end
    
  private
    
    def stories(since)
      logger.info('Loading Pivotal Tracker stories')
      
      since_str = since.strftime('%d %b %Y')
  
      stories = PivotalTracker::Story.find(:all, :params => {
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
        
        Event.new(
          :title => story.name,
          :date => story.updated_at,
          :instigator => instigator,
          :url => story.url,
          :type => :story
        )
      end
    rescue
      logger.warn("Could not load stories: #{$!}")
      []
    end

    def commits(since)
      logger.info('Loading GitHub repositories')

      repositories = Octopi::Repository.find(:user => 'burtcorp')
      
      logger.debug("Found #{repositories.size} repositories")
      
      logger.info('Loading GitHub commits')

      commits = repositories.inject([]) do |c, repository|
        c += repository.commits
        c
      end
      
      logger.debug("Found #{commits.size} commits")

      #<Octopi::Repository:0x104e2ec30 @url="https://github.com/burtcorp/rich_log_server", @owner=#<Octopi::User:0x104e2d7b8 @following_count=2, @created_at=Thu Nov 06 15:20:54 +0100 2008, @public_repo_count=2, @email="gustav@byburt.com", @total_private_repo_count=16, @company="Burt", @disk_usage=262729, @name="Burt", @blog="http://www.byburt.com/", @login="burtcorp", @owned_private_repo_count=16, @followers_count=4, @collaborators=13, @plan=#<Octopi::Plan:0x104e2d448 @private_repos=20, @name="medium", @space=2516582, @collaborators=10>, @gravatar_id="d197c4f3a41430fb304d61beeb3a5c3a", @private_gist_count=1, @location=nil, @public_gist_count=0>, @watchers=3, @open_issues=0, @forks=0, @name="rich_log_server", @homepage="http://log.richmetrics.com", @fork=false, @description="Rich Log Server", @private=true>
      #<Octopi::Commit:0x10511a340 @committed_date="2009-07-06T00:43:40-07:00", @id="0850de284a443e8029c352c931f04d4b5b754148", @author={"name"=>"Theo", "login"=>"iconara", "email"=>"theo@byburt.com"}, @repository=#<Octopi::Repository:0x105132df0 @private=false, @url="http://github.com/burtcorp/jrack_handlers", @owner=#<Octopi::User:0x105131978 @gravatar_id="d197c4f3a41430fb304d61beeb3a5c3a", @location=nil, @public_gist_count=0, @email="gustav@byburt.com", @following_count=2, @created_at=Thu Nov 06 15:20:54 +0100 2008, @name="Burt", @public_repo_count=2, @login="burtcorp", @company="Burt", @blog="http://www.byburt.com/", @followers_count=4>, @watchers=4, @name="jrack_handlers", @homepage="", @open_issues=0, @forks=0, @description="Rack handlers for Java web servers", @fork=false>, @url="http://github.com/burtcorp/jrack_handlers/commit/0850de284a443e8029c352c931f04d4b5b754148", @tree="0d50cdd4566f2b953cc94ffa5119ca7304609bc9", @committer={"name"=>"Theo", "login"=>"iconara", "email"=>"theo@byburt.com"}, @parents=[{"id"=>"419f8bcc3b0279fa3f565bb3f5b887d873cb715b"}], @message="Example scripts", @authored_date="2009-07-06T00:43:40-07:00">

      commits.select { |commit|
        Date.parse(commit.committed_date) >= since
      }.map { |commit|
        Event.new(
          :title => commit.message,
          :date => Time.parse(commit.committed_date),
          :instigator => commit.author['name'],
          :url => commit.url,
          :type => :commit
        )
      }
    rescue
      logger.warn("Could not load commits: #{$!}")
      []
    end
    
    def errors(since)
      logger.info('Loading Hoptoad errors')
      
      errors = Hoptoad::Error.find(:all)
      
      #<Hoptoad::Error:0x104b260b0 @attributes={"notice_hash"=>"1d6097ad97f1bffa1bcbbbfb898ff81d", "created_at"=>Thu Jan 21 02:38:49 UTC 2010, "project_id"=>7597, "updated_at"=>Wed Mar 10 08:57:52 UTC 2010, "action"=>nil, "notices_count"=>65, "resolved"=>false, "id"=>1231518, "lighthouse_ticket_id"=>nil, "error_message"=>"ActionController::MethodNotAllowed: Only put requests are allowed.", "error_class"=>"ActionController::MethodNotAllowed", "controller"=>nil, "rails_env"=>"production", "file"=>"[GEM_ROOT]/gems/actionpack-2.3.5/lib/action_controller/routing/recognition_optimisation.rb", "most_recent_notice_at"=>Wed Mar 10 08:58:16 UTC 2010, "line_number"=>64}, @prefix_options={}>
      
      errors.select { |error|
        error.most_recent_notice_at.to_date >= since
      }.map { |error|
        Event.new(
          :title => error.error_message,
          :date => error.most_recent_notice_at,
          :instigator => nil,
          :url => "http://burt.hoptoadapp.com/errors/#{error.id}",
          :type => :error
        )
      }
    rescue
      logger.warn("Could not load errors: #{$!}")
      []
    end
    
    def case_notes(since)
      logger.info('Loading Highrise users')
      
      users = Highrise::User.find(:all)
      users_by_id = users.inject({}) { |h, user| h[user.id] = user; h }
      
      logger.info('Loading Highrise cases')
      
      cases = Highrise::Kase.find(:all, :from => :open)
      
      logger.info('Loading Highrise notes')
      
      notes = cases.inject([]) do |notes, c|
        notes += c.notes
        notes
      end
      
      #<Highrise::User:0x104b83760 @attributes={"name"=>"Axel von Sydow", "created_at"=>Sat Jun 13 09:21:30 UTC 2009, "updated_at"=>Sat Jun 13 09:21:30 UTC 2009, "id"=>155735, "email_address"=>"axel@byburt.com"}, @prefix_options={}>
      #<Highrise::Kase:0x104b80a38 @attributes={"name"=>"Advertiser customer development", "created_at"=>Wed Jan 20 21:36:31 UTC 2010, "background"=>nil, "updated_at"=>Thu Aug 27 14:07:45 UTC 2009, "group_id"=>nil, "id"=>203730, "owner_id"=>nil, "closed_at"=>nil, "visible_to"=>"Everyone", "author_id"=>nil}, @prefix_options={}>
      #<Highrise::Note:0x104b07570 @attributes={"created_at"=>Thu Aug 27 14:07:45 UTC 2009, "body"=>"Held one hour talk …", "updated_at"=>Wed Jan 20 21:36:31 UTC 2010, "group_id"=>nil, "id"=>14236161, "owner_id"=>nil, "subject_id"=>203730, "collection_type"=>"Kase", "subject_type"=>"Kase", "visible_to"=>"Everyone", "author_id"=>104692, "subject_name"=>"Advertiser customer development", "collection_id"=>203730}, @prefix_options={}>
      
      notes.select { |note|
        note.updated_at >= since
      }.map { |note|
        author = users_by_id[note.author_id]
        Event.new(
          :title => note.subject_name,
          :date => note.updated_at,
          :instigator => author.name,
          :url => "https://burt.highrisehq.com/notes/#{note.id}",
          :type => :case_note
        )
      }
    rescue
      logger.warn("Could not load case notes: #{$!}")
      []
    end
  end
end