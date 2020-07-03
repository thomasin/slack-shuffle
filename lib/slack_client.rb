# frozen_string_literal: true

require 'slack-ruby-client'

# Wraps and pre-configures Slack Ruby Client
class SlackClient
  def self.configure
    return false unless ENV['SLACK_API_TOKEN'] && ENV['SLACK_SIGNING_SECRET']

    Slack.configure do |config|
      config.token = ENV['SLACK_API_TOKEN']
    end

    Slack::Events.configure do |config|
      config.signing_secret = ENV['SLACK_SIGNING_SECRET']
      config.signature_expires_in = 60 * 5 # 5 minutes
    end

    true
  end
end
