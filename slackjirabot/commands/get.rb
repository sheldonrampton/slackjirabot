require 'rubygems'
require 'lib/confluence/api/client'
require 'slackjirabot/ticket_list'
require 'slackjirabot/settings_list'
require 'slackjirabot/jira_client'

module SlackJiraBot
  module Commands
    class Get < SlackRubyBot::Commands::Base
      help do
        title 'get'
        desc 'Gets the value of some fields in a JIRA ticket'
        long_desc <<-BEG
The *get* command retrieves some fields from a Jira ticket.
Syntax: *get <ticket-id> (<settings-list>)*
_EXAMPLE:_
get CIVIC-1234 (assignee; summary; duedate)
        BEG
      end
      command 'get' do |client, data, match|
        @display_names = {
          "assignee" => "Assignee",
          "reporter" => "Reporter",
          "description" => "Description",
          "summary" => "Summary",
          "duedate" => "Due Date",
          "customfield_11850" => "Scrum Team",
          "customfield_12451" => "Staging Test Date",
          "customfield_12654" => "Production Test Date",
          "customfield_13050" => "Client",
          "priority" => "Priority"
        }

        issues, settings = match[:expression].scan(/\s*([^\(]+)\((.*)\)\s*/).to_a.flatten
        ticket_list = TicketList.new(issues)
        settings_list = SettingsList.new(settings)

        jira_client = JiraClient.new
        jira_client.Field.map_fields

        ticket_list.tickets.each do |ticket|
          issue = jira_client.Issue.find(ticket)
          client.say(text: "Field values for ticket #{ENV['JIRA_SITE']}browse/#{ticket}:", channel: data.channel)

          settings_list.fields.keys.each do |key|
            case key
            when "assignee"
              client.say(text: "#{@display_names[key]}: #{issue.fields[key]["displayName"]}", channel: data.channel)
            when "reporter"
              client.say(text: "#{@display_names[key]}: #{issue.fields[key]["displayName"]}", channel: data.channel)
            when "priority"
              client.say(text: "#{@display_names[key]}: #{issue.fields[key]["name"]}", channel: data.channel)
            else
              client.say(text: "#{@display_names[key]}: #{issue.fields[key]}", channel: data.channel)
            end
          end
#          client.say(text: "Links: #{settings_list.links}", channel: data.channel)
        end

        settings_list.unmatched_items.each do |key, val|
          client.say(text: "Sorry, I didn't understand #{key}.", channel: data.channel)
        end
      end
    end
  end
end
