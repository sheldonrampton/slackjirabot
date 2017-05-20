require 'rubygems'
require 'slackjirabot/ticket'

module SlackJiraBot
  module Commands
    class Bug < SlackRubyBot::Commands::Base
      help do
        title 'bug'
        desc 'Creates a CIVIC bug report ticket.'
        long_desc <<-BEG
The *bug* command creates a production bug ticket in the CIVIC project of JIRA to document a flaw in software design.
Syntax: *bug <customer-name>: <title> (<settings-list>)*
_EXAMPLE:_
config HHS: fix search indexing (description: Some datasets are not getting added to Solr when the search index is updated.)
        BEG
      end

      command 'bug' do |client, data, match|
        current_user = SlackJiraBot::User.new("<@#{data['user']}>", client)
        ticket = Ticket::new(match[:expression], current_user, "CIVIC-4914", true)
        if ticket
          ticket_url = "#{ENV['JIRA_SITE']}browse/#{ticket.issue.key}"
          client.say(text: "Created JIRA ticket #{ticket_url}", channel: data.channel)
        else
          client.say(text: "Couldn't create ticket.", channel: data.channel)
        end
      end
    end
  end
end
