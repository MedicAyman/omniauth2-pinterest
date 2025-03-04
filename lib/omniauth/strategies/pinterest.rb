require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class Pinterest < OmniAuth::Strategies::OAuth2
      option :client_options, {
        :site => 'https://api-sandbox.pinterest.com',
        :authorize_url => 'https://www.pinterest.com/oauth/',
        :token_url => 'https://api-sandbox.pinterest.com/v5/oauth/token'
      }

      def request_phase
        options[:scope] ||= 'user_accounts:read'
        options[:response_type] ||= 'code'
        super
      end

      info do
        {
          account_type: raw_info['account_type'],
          image: raw_info['profile_image'],
          website_url: raw_info['website_url'],
          nickname: raw_info['username']
        }
      end

      credentials do
        { token: access_token.token }.tap do |hash|
          hash[:refresh_token] = access_token.refresh_token if access_token.refresh_token
          hash[:expires] = access_token.expires?
          hash[:expires_at] = access_token.expires_at
          if refresh_token_expires_in.present?
            hash[:refresh_token_expires_at] = refresh_token_expires_at(refresh_token_expires_in)
          end
        end
      end

      def raw_info
        @raw_info ||= JSON.load(access_token.get('/v5/user_account').body)
      end

      def callback_url
        full_host + script_name + callback_path
      end

      def build_access_token
        options.token_params.merge!(headers: {'Authorization' => basic_auth_header })
        super
      end

      def basic_auth_header
        "Basic " + Base64.strict_encode64("#{options[:client_id]}:#{options[:client_secret]}")
      end

      def refresh_token_expires_in
        access_token.params['refresh_token_expires_in']
      end

      def refresh_token_expires_at(expires_in_seconds)
        Time.now.to_i + expires_in_seconds
      end
    end
  end
end
