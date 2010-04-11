require 'httparty'


module Central
  module Sources
    class Github
      include Logging
            
      def initialize(github_api)
        @github_api = github_api
      end
      
      def events(since)
        logger.info('Loading GitHub repositories')

        repos = @github_api.repositories
        
        logger.debug("Found #{repos.size} repositories")
        
        events = []
        
        repos.each do |repository|
          catch(:all_found) do
            page = 1
          
            loop do
              logger.debug("Loading page #{page} for repository \"#{repository['name']}\"")
            
              cs = @github_api.commits(repository, :page => page)
              
              throw :all_found if cs.empty?
              
              logger.debug("Found #{cs.size} commits")
              
              cs.each do |commit|
                throw :all_found unless Time.parse(commit['committed_date']) >= since
                
                message = commit['message'].split("\n").first
                
                events << Event.new(
                  :id => commit['id'],
                  :title => "#{repository['name']}: #{message}",
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
    end

    class GithubApi
      BASE_URL = 'https://github.com/api/v2/:format'
      REPOSITORIES_URL = BASE_URL + '/repos/show/:user'
      COMMITS_URL = BASE_URL + '/commits/list/:user/:repository/:branch'
      
      def initialize(login, token, http=HTTParty)
        @login, @token, @http = login, token, http
      end
      
      def repositories
        url = REPOSITORIES_URL.sub(':format', 'json').sub(':user', @login)
        result = @http.get(url, :query => {:login => @login, :token => @token})
        if result && result['repositories']
          result['repositories']
        else
          []
        end
      end
      
      def commits(repository, options={})
        options = {:page => 1, :branch => 'master'}.merge(options)
        url = COMMITS_URL.sub(':format', 'json').sub(':user', @login).sub(':repository', repository['name']).sub(':branch', options[:branch])
        url = url.sub('https://', 'http://') unless repository['private']
        result = @http.get(url, :query => {:login => @login, :token => @token, :page => options[:page]})
        if result && result['commits']
          result['commits']
        else
          []
        end
      end
    end
  end
end