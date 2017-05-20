require 'rubygems'
require 'lib/confluence/api/client'
require 'slackjirabot/ticket_list'
require 'slackjirabot/settings_list'
require 'slackjirabot/jira_client'

module SlackJiraBot
  module Commands
    class Set < SlackRubyBot::Commands::Base
      help do
        title 'set'
        desc 'Sets the value of fields in a JIRA ticket'
        long_desc <<-BEG
The *set* command sets values of fields in one or more Jira tickets.
Syntax: *set <ticket-id-list>: (<settings-list>)*
_EXAMPLE:_
set CIVIC-1234, CIVIC-1235 (assignee=David Kinzer; duedate=12/31/2017)
        BEG
      end
      command 'set' do |client, data, match|
        issues, settings = match[:expression].scan(/\s*([^\(]+)\((.*)\)\s*/).to_a.flatten
        ticket_list = TicketList.new(issues)
        settings_list = SettingsList.new(settings)
        jira_client = JiraClient.new
        jira_client.Field.map_fields

        ticket_list.tickets.each do |ticket|
          issue = jira_client.Issue.find(ticket)
          # Save settings.
          issue.save({"fields" => settings_list.fields})

          # Create ticket links
          settings_list.links.each do |linktype, target|
            link = jira_client.Issuelink.build
            if (target['direction'] == 'inward')
              link.save({
                :type => {:name => linktype},
                :inwardIssue => {:key => target['ticket']},
                :outwardIssue => {:key => ticket},
              })
            else
              link.save({
                :type => {:name => linktype},
                :inwardIssue => {:key => ticket},
                :outwardIssue => {:key => target['ticket']},
              })
            end
          end

          client.say(text: "Updated ticket #{ENV['JIRA_SITE']}browse/#{ticket}", channel: data.channel)
        end

        if settings_list.links.length > 0
          client.say(text: "Links added: #{settings_list.links.to_s}", channel: data.channel)
        end
        if settings_list.fields.length > 0
          client.say(text: "Fields updated: #{settings_list.fields.to_s}", channel: data.channel)
        end
        settings_list.unmatched_items.each do |key, val|
          client.say(text: "Sorry, I didn't understand #{key}: #{val}", channel: data.channel)
        end
      end
    end
  end
end
