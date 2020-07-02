# frozen_string_literal: true

require 'json'
require 'slack-ruby-client'

require 'lib/slack_client'
require 'lib/event_responder'

Handler = proc do |req, res|
  slack = SlackClient.new
  respond = EventResponder.new(res)
  request_body = decode_body(req.body)

  unless request_verified?
    message = 'Error verifying this app is authentic'
    return respond.error(400).ephemeral(message)
  end

  attempt_slack_requests! do
    conversation_members = slack.web_api.conversations_members(
      channel: request_body['channel_id']
    )

    respond.success.ephemeral('Shuffling!')
  rescue StandardError => e
    respond.error(400).ephemeral(e.message)
  end
end

def attempt_slack_requests!
  yield
rescue Slack::Web::Api::Errors::ChannelNotFound
  raise 'Channel not found. You may have to invite the `randomiser` app to your channel'
rescue Slack::Web::Api::Errors::SlackError
  raise 'Sorry, we messed something up 😖'
end

def request_verified?(slack, req)
  request_timestamp = req['X-Slack-Request-Timestamp']
  signature = req['X-Slack-Signature']

  slack_request = slack.event(request_timestamp, signature, req.body)
  slack_request.verify!
  slack_request.valid?
rescue StandardError => e
  puts e.to_s
  false
end

def decode_body(body)
  body_array = URI.decode_www_form(body)
  body_array.to_h
end
