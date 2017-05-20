require 'rubygems'
require 'slackjirabot/ticket'

module SlackJiraBot
  module Commands
    class Enhancement < SlackRubyBot::Commands::Base
      help do
        title 'enhance'
        desc 'Creates a CIVIC enhancement request ticket.'
        long_desc <<-BEG
The *enhance* command creates a CIVIC ticket to request a product improvement.
Syntax: *enhance <title> (<settings-list>)*
_EXAMPLE:_
enhance make file_uploads extensions configurable (relates to=NCS-384)
        BEG
      end

      command 'enhance' do |client, data, match|
        current_user = SlackJiraBot::User.new("<@#{data['user']}>", client)
        ticket = Ticket::new(match[:expression], current_user, "CIVIC-4664", true)
        if ticket
          ticket_url = "#{ENV['JIRA_SITE']}browse/#{ticket.issue.key}"
          client.say(text: "Created JIRA task ticket #{ticket_url}", channel: data.channel)
        else
          client.say(text: "Couldn't create ticket.", channel: data.channel)
        end
      end
    end
  end
end
