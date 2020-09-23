# frozen_string_literal: true

require 'json'

# This deals with methods related to a Slack Slash Command
# i.e. the payload from a triggered Slash Command, and subsequent response
# https://api.slack.com/interactivity/slash-commands
class SlackCommandIntegration
  def initialize(req, res)
    @req = req
    @res = res
  end

  def conversation_id
    decoded_body = URI.decode_www_form(@req.body).to_h
    decoded_body['channel_id']
  end

  def verified?
    request_timestamp = @req['X-Slack-Request-Timestamp']
    signature = @req['X-Slack-Signature']

    slack_request = event(request_timestamp, signature, @req.body)
    slack_request.verify!
    slack_request.valid?
  rescue StandardError
    false
  end

  def respond_with(text)
    @res.status = 200
    @res['Content-type'] = 'application/json'
    @res.body = {
      response: 'ephemeral',
      text: text.dup.force_encoding(Encoding::UTF_8)
    }.to_json
  end

  private

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
