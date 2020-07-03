# frozen_string_literal: true

# This deals with methods related to the Slack Web Api
# i.e. querying data, and enacting changes
# https://api.slack.com/web
class SlackWebApiIntegration
  def initialize
    @client = Slack::Web::Client.new
  end

  def conversation_participants(channel_id)
    @client.conversations_members(
      channel: channel_id
    )
  end

  def request_safely
    message = yield
    success(message)
  rescue Slack::Web::Api::Errors::ChannelNotFound
    failure('A bit lost! If this channel is private, add `randomiser`')
  rescue Slack::Web::Api::Errors::SlackError
    failure('Sorry, we messed something up 😖')
  end

  private

  def success(message)
    OpenStruct.new(success?: true, message: message)
  end

  def failure(message)
    OpenStruct.new(success?: false, message: message)
  end
end
