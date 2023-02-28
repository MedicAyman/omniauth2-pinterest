require 'spec_helper'
require 'debug'

describe OmniAuth::Strategies::Pinterest do

  context "client options" do
    before(:all) do
      OmniAuth.config.test_mode = true
    end

    subject do
      OmniAuth::Strategies::Pinterest.new({})
    end

    it 'should have correct site' do
      subject.options.client_options.site.should eq('https://api.pinterest.com')
    end

    it 'should have correct authorize url' do
      subject.options.client_options.authorize_url.should eq('https://www.pinterest.com/oauth/')
    end

    it 'should have correct token url' do
      subject.options.client_options.token_url.should eq('https://api.pinterest.com/v5/oauth/token')
    end

    it "should have default scope" do
      Rack::Test::Session.new(subject, name: 'test')
      subject.request_phase
      subject.options['scope'].should eq('read_public')
    end
  end
end
