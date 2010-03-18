require 'date'
require 'httparty'


module BurtCentral
  module Sources
    class Github
      include Logging
      
      REPOSITORIES_URL = 'https://github.com/api/v2/:format/repos/show/:user'
      COMMITS_URL = 'https://github.com/api/v2/:format/commits/list/:user/:repository/master'
      
      def events(since)
        logger.info('Loading GitHub repositories')

        repos = repositories('burtcorp')
        
        logger.debug("Found #{repos.size} repositories")
        
        events = []
        
        repos.each do |repository|
          catch(:all_found) do
            page = 1
          
            loop do
              logger.debug("Loading page #{page} for repository \"#{repository['name']}\"")
            
              cs = commits('burtcorp', repository, page)
              
              throw :all_found if cs.empty?
              
              logger.debug("Found #{cs.size} commits")
              
              cs.each do |commit|
                throw :all_found unless Time.parse(commit['committed_date']) >= since
                
                events << Event.new(
                  :title => repository['name'] + ': ' + commit['message'].split("\n").first,
                  :date => Time.parse(commit['committed_date']),
                  :instigator => commit['author']['name'],
                  :url => commit['url'],
                  :type => :commit
                )
              end

              page += 1
            end
          end
        end
        
        logger.debug("Found #{events.size} commits in total")
        
        events
      rescue
        logger.warn("Could not load commits: #{$!}")
        logger.debug("Backtrace: #{$!.backtrace.join("\n")}")
        []
      end
      
    private
    
      def repositories(user)
        url = REPOSITORIES_URL.sub(':format', 'json').sub(':user', user)
        result = HTTParty.get(url, :query => {:login => login, :token => token})
        if result && result['repositories']
          result['repositories']
        else
          []
        end
      end
      
      def commits(user, repository, page=1)
        url = COMMITS_URL.sub(':format', 'json').sub(':user', user).sub(':repository', repository['name'])
        url = url.sub('https://', 'http://') unless repository['private']
        result = HTTParty.get(url, :query => {:login => login, :token => token, :page => page})
        if result && result['commits']
          result['commits']
        else
          []
        end
      end
      
      def login
        raise 'Github login not configured'
      end
      
      def token
        raise 'Github token not configured'
      end
      
    end
  end
end