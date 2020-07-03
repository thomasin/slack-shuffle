# frozen_string_literal: true

require 'lib/slack_client'
require 'lib/slack_web_api_integration'
require 'lib/slack_command_integration'

# Business logic/glue class
class SlashCommand
  def self.process(command, api)
    unless command.verified?
      message = 'Error verifying this app is authentic'
      return command.respond_with(message)
    end

    result = api.request_safely do
      conversation_id = command.conversation_id
      puts api.conversation_participants(conversation_id)
      'Shuffling!'
    end

    command.respond_with(result.message)
  end
end

Handler = proc do |req, res|
  configuration_successful = SlackClient.configure

  command = SlackCommandIntegration.new(req, res)
  api = SlackWebApiIntegration.new

  if configuration_successful
    SlashCommand.process(command, api)
  else
    command.respond_with('We messed up app configuration Whoops')
  end
end
