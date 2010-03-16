require 'date'
require 'octopi'


module BurtCentral
  module Sources
    class Github
      include Logging
      
      def events(since)
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
      
    end
  end
end