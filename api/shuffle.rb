# frozen_string_literal: true

require 'net/http'
require 'slack-ruby-client'

require 'lib/slack_client'

Handler = proc do |req, res|
  slack = SlackClient.configured
  verify_request!(slack, req)

  conversation_members = slack.web_api.conversations_members(
    channel: req.body.channel_id
  )

  puts conversation_members

  res.status = 200
  res['Content-Type'] = 'text/text; charset=utf-8'
  res.body = {
    response_type: 'ephemeral',
    text: 'shuffling (:'
  }
end

def verify_request!(slack, req)
  slack_request = slack.event(req)
  slack_request.verify!
end
