require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class Pinterest < OmniAuth::Strategies::OAuth2
      option :client_options, {
        :ssl => { verify: false },
        :site => 'https://api.pinterest.com',
        :authorize_url => 'https://www.pinterest.com/oauth/',
        :token_url => 'https://api.pinterest.com/v5/oauth/token'
      }

      def request_phase
        options[:scope] ||= 'read_public'
        options[:response_type] ||= 'code'
        super
      end

      credentials do
        {
          token: access_token.token,
          refresh_token: access_token.refresh_token,
          expires: access_token.expires_in.present?,
          expires_at: access_token.expires_in.seconds.from_now,
          refresh_token_expires_at: access_token.params['refresh_token_expires_in'].seconds.from_now
        }
      end

      def callback_url
        full_host + script_name + callback_path
      end

      def build_access_token
        Rails.logger.debug "Omniauth build access token"
        options.token_params.merge!(:headers => {'Authorization' => basic_auth_header })
        super
      end

      def basic_auth_header
        "Basic " + Base64.strict_encode64("#{options[:client_id]}:#{options[:client_secret]}")
      end
    end
  end
end
