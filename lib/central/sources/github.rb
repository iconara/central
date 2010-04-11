require 'set'
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
        
        logger.debug { "Found #{repos.size} repositories" }
        
        commit_ids = Set.new
        
        events = []
        
        repos.each do |repository|
          branches = @github_api.branches(repository)
          
          logger.debug { %(The repository "#{repository['name']} has #{branches.size} branches: "#{branches.keys.join('", "')}") }
          
          branches.keys.each do |branch|
            catch(:all_found) do
              page = 1
          
              loop do
                logger.debug { %(Loading page #{page} for repository "#{repository['name']}/#{branch}") }
            
                cs = @github_api.commits(repository, :branch => branch, :page => page)
              
                throw :all_found if cs.empty?
              
                logger.debug { "Found #{cs.size} commits" }
              
                cs.each do |commit|
                  throw :all_found unless Time.parse(commit['committed_date']) >= since
                
                  unless commit_ids.include?(commit['id'])
                    message = commit['message'].split("\n").first
                
                    events << Event.new(
                      :id => commit['id'],
                      :title => "#{repository['name']}/#{branch}: #{message}",
                      :date => Time.parse(commit['committed_date']),
                      :instigator => commit['author']['name'],
                      :url => commit['url'],
                      :type => :commit
                    )
                    
                    commit_ids << commit['id']
                  end
                end

                page += 1
              end
            end
          end
        end
        
        logger.debug { "#{events.size} commits in total since #{since}" }
        
        events
      rescue
        logger.warn("Could not load commits: #{$!}")
        logger.debug { "Backtrace: #{$!.backtrace.join("\n")}" }
        []
      end
    end

    class GithubApi
      BASE_URL = 'https://github.com/api/v2/:format'
      REPOSITORIES_URL = BASE_URL + '/repos/show/:user'
      BRANCHES_URL = REPOSITORIES_URL + '/:repository/branches'
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
      
      def branches(repository)
        url = prepare_url(BRANCHES_URL, repository['private'], :repository => repository['name'])
        result = @http.get(url, :query => query_params)
        if result && result['branches']
          result['branches']
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
      
    private
    
      def prepare_url(url, ssl=true, params={})
        url = url.sub('https://', 'http://') unless ssl
        params = {:format => 'json', :user => @login}.merge(params)
        params.keys.inject(url) do |url, param|
          url.sub(":#{param}", params[param])
        end
      end
      
      def query_params(extras={})
        {:login => @login, :token => @token, :page => 1}.merge(extras)
      end
    end
  end
end