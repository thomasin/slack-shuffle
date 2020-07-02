# frozen_string_literal: true

require 'slack-ruby-client'

# Connect to the fully configured Slack Client
class SlackClient
  def self.configured
    Slack.configure do |config|
      config.token = ENV['SLACK_API_TOKEN']
      raise 'Missing ENV[SLACK_API_TOKEN]!' unless config.token
    end

    Slack::Web::Client.new
  end
end
