require 'slackjirabot/customer'
require 'slackjirabot/user'
require 'rubygems'

module SlackJiraBot
  module Commands
    class Describe < SlackRubyBot::Commands::Base
      help do
        title 'describe'
        desc 'Gives info about a customer or person'
        long_desc <<-BEG
The *describe* command returns information about a customer or person (more specifically, a Granicus employee).
For _customers_, it will return info includig a full ("canonical") name, abbreviation, and links to the customer website, github repo and Confluence documentation. 
For _people_, it will return info including the employee's Slack and Jira handles.
Syntax: *describe <name>*
_EXAMPLES:_
describe HHS
describe louisville
describe Krista Brenner
        BEG
      end

      command 'describe' do |client, data, match|
        expression = match[:expression]
        if expression =~ /<http:\/\/.*\|(.*)>/ 
          expression = expression.scan(/<http:\/\/.*\|(.*)>/).to_a.flatten[0]
        end
        customer = Customer.new(expression)
        if customer.properties[:abbrev] == 'NOT FOUND'
          user = SlackJiraBot::User::new(expression, client)
          if user.slack_user == nil
            client.say(text: "Sorry, I don't know anything about #{expression}.", channel: data.channel)
          else
            client.say(text: "Jira username is #{user.jira_username}.", channel: data.channel)
            client.say(text: "Jira display name is #{user.jira_display_name}.", channel: data.channel)
            client.say(text: "Slack handle is <@#{user.slack_user.id}>.", channel: data.channel)
            client.say(text: "Slack full name is #{user.slack_user.real_name}.", channel: data.channel)
          end
        else
          http = "http://"
          if (customer.properties[:https])
            http = "https://"
          end
          client.say(text: "The #{customer.properties[:fullname]} (#{customer.properties[:abbrev]}) lives at #{http}#{customer.properties[:domain]}", channel: data.channel)
          client.say(text: "Deployment history is at #{ENV['CONFLUENCE_SITE']}/display/NCKB/#{customer.properties[:abbrev]}+deployments", channel: data.channel)
          if customer.properties[:dev_site] != ''
            client.say(text: "Dev site: #{http}#{customer.properties[:dev_site]}", channel: data.channel)
            client.say(text: "Test site: #{http}#{customer.properties[:stage_site]}", channel: data.channel)
          end
          if customer.properties[:repo] != ''
            client.say(text: "Code repo: #{customer.properties[:repo]}", channel: data.channel)
          end
        end    
      end
    end
  end
end
