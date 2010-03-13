module Hoptoad
  class Error
    self.site       = ''
    self.auth_token = ''
  end
end

module PivotalTracker
  class Story
    self.site = ''
    headers['X-TrackerToken'] = ''
  end
end

module Octopi
  Api.api = AuthApi.instance
  Api.api.login = ''
  Api.api.token = ''
end

module Highrise
  class Base < ActiveResource::Base
    self.site = ''
  end
end