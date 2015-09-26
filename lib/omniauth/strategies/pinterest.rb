require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class Pinterest < OmniAuth::Strategies::OAuth2
      option :client_options, {
        :site => 'https://api.pinterest.com',
        :authorize_url => 'https://api.pinterest.com/oauth/',
        :token_url => 'https://api.pinterest.com/v1/oauth/token'
      }

      def request_phase
        options[:scope] ||= 'read_public'
        options[:response_type] ||= 'code'
        super
      end

      uid { raw_info['id'] }

      info do
        {
          'nickname' => raw_info['url'] && raw_info['url'].split('/').last,
          'first_name' => raw_info['first_name'],
          'last_name' => raw_info['last_name'],
          'name' => [raw_info['first_name'],raw_info['last_name']].compact.join(' ')
        }
      end

      def raw_info
        @data ||= access_token.params["user"]
        unless @data
          access_token.options[:mode] = :query
          access_token.options[:param_name] = "access_token"
          @data ||= access_token.get('/v1/me').parsed['data'] || {}
        end
        @data
      end
    end
  end
end
