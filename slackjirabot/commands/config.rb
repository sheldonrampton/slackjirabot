require 'date'

module SlackJiraBot
  module Commands
    class Config < SlackRubyBot::Commands::Base
      help do
        title 'config'
        desc 'Creates a Change Request ticket'
        long_desc <<-BEG
The *config* command creates a Change Request ticket in the Change Requests (CR) project of JIRA to document a configuration change.
Syntax: *config <customer-name>: <title> (<settings-list>)*
_EXAMPLE:_
config HHS: change colorizer settings (description: At customer's request, changed everything from blue to red.)
        BEG

      end

      command 'config', 'configure' do |client, data, match|
        customers, summary, settings = match[:expression].scan(/\s*([^:]*):\s*(.*)\s*\((.*)\)\s*/).to_a.flatten
        summary = summary.strip
        settings_list = SettingsList.new(settings)

        # Standardize the customer names.
        customer_strings = []
        customers.split(',').each do |cust|
          customer = Customer.new(cust.strip)
          if customer.properties[:abbrev] == 'NOT FOUND'
            customer_strings << cust.strip
          else
            customer_strings << customer.properties[:abbrev]
          end
        end
        customers = customer_strings.join(', ')

        # Create Change Request ticket, using an existing Jira issue (CIVIC-4934) as a template.
        jira_client = JiraClient.new
        issue = jira_client.Issue.find('CR-2964')

        # Unless otherwise specified, use the current user as the ticket's reporter and assignee.
        current_user = SlackJiraBot::User.new("<@#{data['user']}>", client)
        if settings_list.fields['assignee'] == nil
          settings_list.fields['assignee'] = {"name" => current_user.jira_username}
        end
        if settings_list.fields['reporter'] == nil
          settings_list.fields['reporter'] = {"name" => current_user.jira_username}
        end

        # Use the template's boilerplate description if the Slackbot command didn't include one.
        if settings_list.fields['description'] == nil
          settings_list.fields['description'] = issue.description
        end
        issuefields = {"fields"=>settings_list.fields.merge({
          "project"           => {"key"=>"CR"},
          "issuetype"         => {"id"=>issue.issuetype.id},
          "summary"           => "Config - " + summary + " - " + customers,
          "duedate"           => Date.parse(Time.now.to_s),
          "priority"          => {"id"=>issue.priority.id},
          # Customer impact field
          "customfield_10251" => issue.customfield_10251,
          # QA field
          "customfield_10454" => issue.customfield_10454,
          # Backout field
          "customfield_10455" => issue.customfield_10455,
        })}

        new_issue = jira_client.Issue.build
        creationresult = new_issue.save(issuefields)
        if (creationresult)
          new_issue.fetch
          client.say(text: "Created JIRA ticket #{ENV['JIRA_SITE']}browse/#{new_issue.key}", channel: data.channel)
# TO DO: Automatically update the ticket to a status of "Done"
#          new_issue_transition = new_issue.transitions.build
#          new_issue_transition.save!('transition' => {'id' => 161})
# TO DO: Automatically create a new related task ticket for the product team if the config change needs to be
# added to the site's code in a future code release.
        else
          client.say(text: "Couldn't create ticket.", channel: data.channel)
        end
      end
    end
  end
end
