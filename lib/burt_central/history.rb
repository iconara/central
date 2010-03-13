module BurtCentral
  class History
    def events(since=Date.today)
      events = stories(since) + commits(since) + errors(since)
      events.sort.reverse
    end
    
  private
    
    def stories(since)
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
    end

    def commits(since)
      burtcorp = Octopi::User.find('burtcorp')

      commits = burtcorp.repositories.inject([]) do |c, repository|
        c += repository.commits
        c
      end
      
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
    end
    
    def errors(since)
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
    end
  end
end