# frozen_string_literal: true

require 'slack-ruby-client'

# Wraps and pre-configures Slack Ruby Client
class SlackClient
  def initialize
    Slack.configure do |config|
      config.token = ENV['SLACK_API_TOKEN']
      raise 'Missing ENV[SLACK_API_TOKEN]!' unless config.token
    end

    Slack::Events.configure do |config|
      config.signing_secret = ENV['SLACK_SIGNING_SECRET']
      config.signature_expires_in = 60 * 5 # 5 minutes
      raise 'Missing ENV[SLACK_SIGNING_SECRET]!' unless config.signing_secret
    end
  end

  def web_api
    Slack::Web::Client.new
  end

  def event(request_timestamp, signature, body)
    # To fit code located:
    # https://github.com/dblock/slack-ruby-client/blob/master/lib/slack/events/request.rb
    headers = {
      'X-Slack-Request-Timestamp' => request_timestamp,
      'X-Slack-Signature' => signature
    }

    http_request = OpenStruct.new(
      headers: headers,
      body: OpenStruct.new(read: body)
    )

    Slack::Events::Request.new(http_request)
  end
end
