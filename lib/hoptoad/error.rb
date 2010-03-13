require 'active_resource'


module Hoptoad
  class Error < ActiveResource::Base
    class << self
      def auth_token
        @@auth_token
      end
    
      def auth_token=(token)
        @@auth_token = token
      end

      def find(*arguments)
        arguments = append_auth_token_to_params(*arguments)
        super(*arguments)
      end

      def append_auth_token_to_params(*arguments)
        opts = arguments.last.is_a?(Hash) ? arguments.pop : {}
        opts = opts.has_key?(:params) ? opts : opts.merge(:params => {})
        opts[:params] = opts[:params].merge(:auth_token => @@auth_token)
        arguments << opts
        arguments
      end
    end
  end
end