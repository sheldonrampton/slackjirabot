require 'date'
require 'rubygems'
require 'slackjirabot/jira_client'
require 'slackjirabot/customer'

module SlackJiraBot
  class Ticket
    attr_accessor :issue, :settings_list, :summary, :template, :customers

     # Create the object
    def initialize(expression, current_user, template_key, inherit_from_blocker=false)
      customers, summary, settings = parse_expression(expression)
      set_customers_string(customers)
      set_summary_string(summary)

      # Retrieve the ticket template.
      jira_client = JiraClient.new
      @template = jira_client.Issue.find(template_key)

      set_settings_list(settings, jira_client, current_user, inherit_from_blocker)
      create_issue(jira_client)
    end

    # Parse the expression passed in to the command
    def parse_expression(expression)
      expression.gsub! /<https?:[^\|]*\|([^>]*)>/, '\1'
      first_part, settings = expression.scan(/([^\(]*)\((.*)\)\s*/).to_a.flatten
      first_part = first_part.split(':', 2)
      if (first_part.length == 1)
        customers = ''
        summary = first_part[0].strip
      else
        customers = first_part[0].strip
        summary = first_part[1].strip
      end
      [customers, summary, settings]
    end

    # Create links to other tickets.
    def create_links(settings_list, jira_client)
      @settings_list.links.each do |linktype, target|
        link = jira_client.Issuelink.build
        if (target['direction'] == 'inward')
          link.save({
            :type => {:name => linktype},
            :inwardIssue => {:key => target['ticket']},
            :outwardIssue => {:key => @issue.key},
          })
        else
          link.save({
            :type => {:name => linktype},
            :inwardIssue => {:key => @issue.key},
            :outwardIssue => {:key => target['ticket']},
          })
        end
      end
    end

    # Standardize the customer names.
    def set_customers_string(customers)
      customer_strings = []
      customers.split(',').each do |cust|
        customer = Customer.new(cust.strip)
        if customer.properties[:abbrev] == 'NOT FOUND'
          customer_strings << cust.strip
        else
          customer_strings << customer.properties[:abbrev]
        end
      end
      @customers = customer_strings.join(', ')
    end

    # Standardize the summary string.
    def set_summary_string(summary)
      @summary = summary.strip
      if @customers != ''
        @summary = @summary + " - " + @customers
      end
    end

    # Standardize the settings list.
    def set_settings_list(settings, jira_client, current_user, inherit_from_blocker)
      @settings_list = SettingsList.new(settings)
      # Unless otherwise specified, use the current user as the ticket's reporter and assignee.
      if @settings_list.fields['assignee'] == nil
        @settings_list.fields['assignee'] = {"name" => current_user.jira_username}
      end
      if @settings_list.fields['reporter'] == nil
        @settings_list.fields['reporter'] = {"name" => current_user.jira_username}
      end

      if @settings_list.fields['description'] == nil
        if inherit_from_blocker && (@settings_list.links['Blocks'] != nil || @settings_list.links['Relates'] != nil)
          if @settings_list.links['Blocks'] != nil
            related_ticket_key = @settings_list.links['Blocks']['ticket']
          else
            related_ticket_key = @settings_list.links['Relates']['ticket']
          end
          related_issue = jira_client.Issue.find(related_ticket_key)
          @settings_list.fields['description'] = "Reported from #{related_ticket_key}:\n\n" + related_issue.description
        else
          @settings_list.fields['description'] = issue.description
        end
      end
      if @settings_list.fields['duedate'] == nil
        @settings_list.fields['duedate'] = Date.parse(Time.now.to_s)
      end
      if @settings_list.fields['priority'] == nil
        @settings_list.fields['priority'] = {"id"=>@template.priority.id}
      end
    end

    # Create the issue for this tickets.
    def create_issue(jira_client)
      issuefields = {
        "fields"     => @settings_list.fields.merge({
          "project"    => {"key"=>@template.project.key},
          "issuetype"  => {"id"=>@template.issuetype.id},
          "summary"    => @summary,
        })
      }

      @issue = jira_client.Issue.build
      if @issue.save(issuefields)
        @issue.fetch
        create_links(@settings_list, jira_client)
      else
        @issue = false
      end
    end
  end
end
