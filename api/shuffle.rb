# frozen_string_literal: true

require 'net/http'
require 'slack-ruby-client'

require 'lib/slack_client'

Handler = proc do |req, res|
  slack = SlackClient.new
  verify_request!(slack, req)

  request_body = decode_body(req.body)

  conversation_members = slack.web_api.conversations_members(
    channel: request_body['channel_id']
  )

  res.status = 200
  res['Content-Type'] = 'application/json; charset=utf-8'
  res.body = {
    response_type: 'ephemeral',
    text: 'shuffling (:'
  }
end

def verify_request!(slack, req)
  slack_request = slack.event(req)
  slack_request.verify!
  raise 'Invalid signature' unless slack_request.valid?
end

def decode_body(body)
  body_array = URI.decode_www_form(body)
  body_array.to_h
end
