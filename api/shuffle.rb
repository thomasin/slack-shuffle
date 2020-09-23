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
      participants = api.conversation_participants(conversation_id).members

      # Some might be bots
      conversation_humans = []
      api.users_list do |response|
        response.members.each do |member|
          next if member.is_bot || member.is_app_user
          next unless participants.include?(member.id)

          conversation_humans << { id: member.id, name: member.name }
        end
      end

      conversation_humans.shuffle.each_with_index.inject("") do |message, (human, index)|
        "#{index + 1}. #{human.name}\n"
      end
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
