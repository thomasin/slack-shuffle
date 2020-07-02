# frozen_string_literal: true

require 'slack-ruby-client'

# Wraps and pre-configures Slack Ruby Client
class SlackClient
  def self.configured
    Slack.configure do |config|
      config.token = ENV['SLACK_API_TOKEN']
      raise 'Missing ENV[SLACK_API_TOKEN]!' unless config.token
    end

    Slack::Events.configure do |config|
      config.signing_secret = ENV['SLACK_SIGNING_SECRET']
      raise 'Missing ENV[SLACK_SIGNING_SECRET]!' unless config.signing_secret
    end
  end

  def web_api
    Slack::Web::Client.new
  end

  def event(req)
    headers = {
      'X-Slack-Request-Timestamp': req['X-Slack-Request-Timestamp'],
      'X-Slack-Signature': req['X-Slack-Signature'],
    }

    # The request object used by Now does not match up to the one expected
    # by Slack::Events::Request, code located:
    # https://github.com/dblock/slack-ruby-client/blob/master/lib/slack/events/request.rb
    http_request = OpenStruct.new(headers: headers, body: body)
    Slack::Events::Request.new(http_request)
  end
end
