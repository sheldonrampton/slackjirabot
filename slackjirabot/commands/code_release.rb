require 'rubygems'
require 'slackjirabot/qa_ticket'

module SlackJiraBot
  module Commands
    class CodeRelease < SlackRubyBot::Commands::Base
      help do
        title 'cr'
        desc 'Creates Code Release ticket.'
        long_desc <<-BEG
The *cr* or *code_release* command creates a Code Release ticket in the Change Requests (CR) project.
Syntax: *cr <customer-name>: <title> (<settings-list>)*
_EXAMPLE:_
cr HHS: patch release to DKAN 1.12.14 (assignee: Sheldon Rampton; description: This code release upgrades the website to DKAN 7.x-1.12.14 and also fixes some customer-specific bugs.)
        BEG
      end

      command 'cr', 'code release' do |client, data, match|
        current_user = SlackJiraBot::User.new("<@#{data['user']}>", client)
        generate_list(match[:expression]).each do |expression|
          ticket = CRTicket::new(expression, current_user, "CR-2922", true)
          if ticket.issue
            ticket_url = "#{ENV['JIRA_SITE']}browse/#{ticket.issue.key}"
            client.say(text: "Created JIRA ticket #{ticket_url}", channel: data.channel)
          else
            client.say(text: "Couldn't create ticket.", channel: data.channel)
          end
        end
      end
    
      class << self
        # Generates a list of ticket creation strings
        def generate_list(expression)
          expression.gsub! /<https?:[^\|]*\|([^>]*)>/, '\1'
          first_part, settings = expression.scan(/([^\(]*)\((.*)\)\s*/).to_a.flatten
          first_part = first_part.split(':', 2)
          list = []
          if (first_part.length != 1)
            summary = first_part[1].strip
            first_part[0].strip.split(',').each do |cust|
              list << cust.strip + ': ' + summary + ' (' + settings + ')'
            end
          end
          list
        end
      end
    end
  end
end

