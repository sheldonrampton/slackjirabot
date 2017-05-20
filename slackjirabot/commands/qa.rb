require 'rubygems'
require 'slackjirabot/qa_ticket'

module SlackJiraBot
  module Commands
    class QualityAssurance < SlackRubyBot::Commands::Base
      help do
        title 'qa'
        desc 'Creates a ticket to perform QA on a DKAN site.'
        long_desc <<-BEG
The *qa* command creates a Task in the CIVIC project to do QA review of a DKAN site.
It also creates checklists in Confluence for user acceptance testing and deployment.
Syntax: *qa <customer-name>: <title> (<settings-list>)*
_EXAMPLE:_
qa HHS: patch release and custom bugfix (blocks: CR-3327; version: 1.12.13; duedate=12/31/2017)
        BEG
      end

      command 'qa' do |client, data, match|
        client.say(text: "OK, give me a minute here...", channel: data.channel)
        current_user = SlackJiraBot::User.new("<@#{data['user']}>", client)
        customer, summary, settings = match[:expression].scan(/\s*([^:]*):\s*(.*)\s*\((.*)\)\s*/).to_a.flatten
        summary = summary.strip
        qa_ticket = QATicket::new(customer, summary, settings, current_user)
        if qa_ticket
          qa_ticket_url = "#{ENV['JIRA_SITE']}browse/#{qa_ticket.tasks[:parent].key}"
          client.say(text: "Created JIRA QA ticket #{qa_ticket_url}", channel: data.channel)
          deploy_checklist_url = "#{ENV['CONFLUENCE_SITE']}#{qa_ticket.checklists[:deploy]['_links']['webui']}"
          uat_checklist_url = "#{ENV['CONFLUENCE_SITE']}#{qa_ticket.checklists[:uat]['_links']['webui']}"
          client.say(text: "Created Deployment QA checklist #{deploy_checklist_url}", channel: data.channel)
          client.say(text: "Created Confluence UAT checklist: #{uat_checklist_url}", channel: data.channel)
        else
          client.say(text: "Couldn't create ticket.", channel: data.channel)
        end
      end
    end
  end
end
