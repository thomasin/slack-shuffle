# frozen_string_literal: true

require 'net/http'
require 'slack-ruby-client'

require '../lib/slack_client'

slack = SlackClient.configured

Handler = proc do |req, res|
  verify_request!(req)

  conversation_members = slack.conversations_members(
    channel: channel_id
  )

  puts conversation_members

  res.status = 200
  res['Content-Type'] = 'text/text; charset=utf-8'
  res.body = {
    response_type: 'ephemeral',
    text: 'shuffling (:'
  }
end

def verify_request!
  slack_request = Slack::Events::Request.new(req)
  slack_request.verify!
end
