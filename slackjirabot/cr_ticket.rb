require 'date'
require 'rubygems'
require 'slackjirabot/jira_client'

module SlackJiraBot
  class CRTicket < SlackJiraBot::Ticket

    # Override inherited method.
    def set_settings_list(settings, jira_client, current_user, inherit_from_blocker)
      super(settings, jira_client, current_user, inherit_from_blocker)
      substition_string = "[DESCRIPTION]"
      new_description = @template.description
      new_description.sub! substition_string, settings_list.fields['description']

      substition_string = "[CUSTOMER]"
      new_description.gsub! substition_string, @customers

      @settings_list.fields['description'] = new_description
      @settings_list.fields['customfield_12451'] = (Date.parse(@settings_list.fields['duedate'].to_s)-1).to_s
      @settings_list.fields['customfield_12654'] = @settings_list.fields['duedate'].to_s + "T15:00:00.000-0600"
      @settings_list.fields['components'] = [{'id' => @template.components[0].attrs['id']}]
      @settings_list.fields['customfield_10454'] = @template.customfield_10454
      @settings_list.fields['customfield_10455'] = @template.customfield_10455
      @settings_list.fields.tap{|x| x.delete('priority')}
    end
  end
end
