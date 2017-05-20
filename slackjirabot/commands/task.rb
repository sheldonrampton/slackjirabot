require 'rubygems'
require 'slackjirabot/ticket'

module SlackJiraBot
  module Commands
    class Task < SlackRubyBot::Commands::Base
      help do
        title 'task'
        desc 'Creates a CIVIC task ticket.'
        long_desc <<-BEG
The *task* command creates a ticket of type Task in the CIVIC project.
Syntax: *task <title> (<settings-list>)*
_EXAMPLE:_
task Write release notes for DKAN 1.14 (relates to=NCS-384)
        BEG
      end

      command 'task' do |client, data, match|
        current_user = SlackJiraBot::User.new("<@#{data['user']}>", client)
        ticket = Ticket::new(match[:expression], current_user, "CIVIC-4668", true)
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
