require 'date'
require 'rubygems'
require 'lib/confluence/api/client'
require 'slackjirabot/jira_client'

module SlackJiraBot
  class QATicket
  	attr_accessor :tasks, :checklists

    # Create the object, based on the following values:
    # - customer: the name of the customer
    # - summary: a brief summary of the work being QA'd, e.g., "patch release"
    # - settings: a list of settings to be applied to the ticket, such as due date, assignee, etc.
    def initialize(customer, summary, settings, current_user)
      # A QA ticket consists of three CIVIC Tasks tickets in Jira (a parent task with two subtasks).
      @tasks = {
        :parent => nil,
        :uat => nil,
        :deploy => nil,
      }
      # QA tickets include links to two checklists -- a deployment checklist and a UAT checklist.
      @checklists = {
        :deploy => nil,
        :uat => nil,
      }
      settings_list = SettingsList.new(settings)
      # Unless otherwise specified, use the current user as the ticket's reporter and assignee.
      if settings_list.fields['assignee'] == nil
        settings_list.fields['assignee'] = {"name" => current_user.jira_username}
      end
      if settings_list.fields['reporter'] == nil
        settings_list.fields['reporter'] = {"name" => current_user.jira_username}
      end
      customer = Customer.new(customer)
      jira_client = JiraClient.new

      # Create parent QA task, using an existing Jira issue (CIVIC-4934) as a template.
      template_key = 'CIVIC-4934'
      issue = jira_client.Issue.find(template_key)
      pattern = "[CR_TICKET]"
      new_description = issue.description
      if settings_list.links['Blocks']
        new_description.sub! pattern, settings_list.links['Blocks']['ticket']
      end

      issuefields = {"fields"=>settings_list.fields.merge({
        "project"           => {"key"=>"CIVIC"},
        "issuetype"         => {"id"=>issue.issuetype.id},
        "summary"           => "QA - " + summary + " - " + customer.properties[:abbrev],
        "description"       => new_description,
        "priority"          => {"id"=>issue.priority.id},
      })}

      @tasks[:parent] = jira_client.Issue.build
      creationresult = @tasks[:parent].save(issuefields)
      if (creationresult)
        @tasks[:parent].fetch

        # Create ticket links
        settings_list.links.each do |linktype, target|
          link = jira_client.Issuelink.build
          if (target['direction'] == 'inward')
            link.save({
              :type => {:name => linktype},
              :inwardIssue => {:key => target['ticket']},
              :outwardIssue => {:key => @tasks[:parent].key},
            })
          else
            link.save({
              :type => {:name => linktype},
              :inwardIssue => {:key => @tasks[:parent].key},
              :outwardIssue => {:key => target['ticket']},
            })
          end
        end

        # create UAT checklist subtask, based on a template.
        qa_ticket_uat_template = 'CIVIC-4935'
        issue = jira_client.Issue.find(qa_ticket_uat_template)
        issuefields = {"fields"=>settings_list.fields.merge({
          "project"           => {"key"=>"CIVIC"},
          "parent"            => {"id" => @tasks[:parent].id},
          "issuetype"         => {"id"=>issue.issuetype.id},
          "summary"           => "UAT checklist - " + summary + " - " + customer.properties[:abbrev],
          "description"       => issue.description,
          "priority"          => {"id"=>issue.priority.id},
        })}
        @tasks[:uat] = jira_client.Issue.build
        creationresult = @tasks[:uat].save(issuefields)
        @tasks[:uat].fetch

        # create Deployment checklist subtask, based on a template.
        qa_ticket_deploy_template = 'CIVIC-4936'
        issue = jira_client.Issue.find(qa_ticket_deploy_template)
        issuefields = {"fields"=>settings_list.fields.merge({
          "project"           => {"key"=>"CIVIC"},
          "parent"            => {"id" => @tasks[:parent].id},
          "issuetype"         => {"id"=>issue.issuetype.id},
          "summary"           => "Deployment checklist - " + summary + " - " + customer.properties[:abbrev],
          "description"       => issue.description,
          "priority"          => {"id"=>issue.priority.id},
        })}
        @tasks[:deploy] = jira_client.Issue.build
        creationresult = @tasks[:deploy].save(issuefields)
        @tasks[:deploy].fetch

         qa_ticket_url = "#{ENV['JIRA_SITE']}browse/#{@tasks[:parent].key}"
        http = "http://"
        if (customer.properties[:https])
          http = "https://"
        end
        dev_site     = "#{http}#{customer.properties[:dev_site]}"
        stage_site   = "#{http}#{customer.properties[:stage_site]}"
        prod_site    = "#{http}#{customer.properties[:domain]}"

        # Create the Confluence pages
        username = ENV['JIRA_USERNAME']
        password = ENV['JIRA_PASSWORD']
        space    = 'NCKB'
        url      = ENV['CONFLUENCE_SITE']
        confluence_client = Confluence::Api::Client.new(username, password, url)

        parent_page = confluence_client.get({spaceKey: space, title: customer.properties[:abbrev] + " deployments"})[0]
        uat_deploy_template = confluence_client.get({spaceKey: space, title: 'Deploy_QA_Template', expand: 'body.storage'})[0]["body"]["storage"]["value"]
        uat_qa_template_1 = confluence_client.get({spaceKey: space, title: 'UAT_QA_Template_1', expand: 'body.storage'})[0]["body"]["storage"]["value"]
        uat_qa_template_2 = confluence_client.get({spaceKey: space, title: 'UAT_QA_Template_2', expand: 'body.storage'})[0]["body"]["storage"]["value"]

        # String replacements
        uat_qa_template_1.sub! "JIRA_TICKET", "<a href=\"#{qa_ticket_url}\">#{qa_ticket_url}</a>"
        uat_qa_template_1.sub! "DKAN_VERSION", settings_list.version
        uat_qa_template_1.sub! "DEV_SITE", "<a href=\"#{dev_site}\">#{dev_site}</a>"
        uat_qa_template_1.sub! "STAGE_SITE", "<a href=\"#{stage_site}\">#{stage_site}</a>"
        uat_qa_template_1.sub! "PROD_SITE", "<a href=\"#{prod_site}\">#{prod_site}</a>"


        checklist_content = uat_qa_template_1 + uat_qa_template_2
        if customer.properties[:abbrev] == 'HHS'
          uat_qa_template_hhs = confluence_client.get({spaceKey: space, title: 'UAT_QA_Template_HHS', expand: 'body.storage'})[0]["body"]["storage"]["value"]
          checklist_content = checklist_content + uat_qa_template_hhs
        elsif customer.properties[:abbrev] == 'GOSA'
          uat_qa_template_gosa = confluence_client.get({spaceKey: space, title: 'UAT_QA_Template_GOSA', expand: 'body.storage'})[0]["body"]["storage"]["value"]
          checklist_content = checklist_content + uat_qa_template_gosa
        end

        deploy_content = uat_qa_template_1 + uat_deploy_template

        @checklists[:deploy] = confluence_client.create({
          type: "page",
          title: "#{customer.properties[:abbrev]} Deployment QA checklist, " +  Date.parse(Time.now.to_s).to_s,
          space: {key: space},
          body: {
            storage: {
              value: deploy_content,
              representation: "storage"
            }
          },
          ancestors:[
            {
              type:"page",
              id: parent_page['id']
            }
          ]
        })

        @checklists[:uat] = confluence_client.create({
          type: "page",
          title: "#{customer.properties[:abbrev]} UAT QA checklist, " + Date.parse(Time.now.to_s).to_s,
          space: {key: space},
          body: {
            storage: {
              value: checklist_content,
              representation: "storage"
            }
          },
          ancestors:[
            {
              type:"page",
              id: @checklists[:deploy]['id']
            }
          ]
        })

        # Add checklist URLs to JIRA tickets
        @tasks[:parent].description.sub! "UAT_CHECKLIST", "#{ENV['CONFLUENCE_SITE']}#{@checklists[:uat]['_links']['webui']}"
        @tasks[:parent].description.sub! "DEPLOY_CHECKLIST", "#{ENV['CONFLUENCE_SITE']}#{@checklists[:deploy]['_links']['webui']}"
        @tasks[:uat].description.sub! "UAT_CHECKLIST", "#{ENV['CONFLUENCE_SITE']}#{@checklists[:uat]['_links']['webui']}"
        @tasks[:deploy].description.sub! "DEPLOY_CHECKLIST", "#{ENV['CONFLUENCE_SITE']}#{@checklists[:deploy]['_links']['webui']}"
        @tasks[:parent].save({"fields"=>{
          "description"       => @tasks[:parent].description,
        }})
        @tasks[:uat].save({"fields"=>{
          "description"       => @tasks[:uat].description,
        }})
        @tasks[:deploy].save({"fields"=>{
          "description"       => @tasks[:deploy].description,
        }})
      else
        @tasks = false
      end
    end
  end
end
