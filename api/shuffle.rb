# frozen_string_literal: true

require 'net/http'

Slack.configure do |config|
  config.token = ENV['SLACK_API_TOKEN']
end

Handler = proc do |req, res|
  slack_request = Slack::Events::Request.new(http_request)
  slack_request.verify!
  conversation_members = members_of(req.body.channel_id)

  res.status = 200
  res['Content-Type'] = 'text/text; charset=utf-8'
  res.body = {
    response_type: 'ephemeral',
    text: 'shuffling (:'
  }
end

def reply_with(_shuffled_members, endpoint)
  query_params = {
    channel: channel_id,
    token: token
  }

  url = URI::HTTPS.build(host: endpoint, query: URI.encode_www_form(query_params))

  req = Net::HTTP::Post.new(url)
  res = Net::HTTP.start(url.host, url.port) do |http|
    http.request(req)
  end

  res.body.members
end
