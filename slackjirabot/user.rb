require 'slackjirabot/jira_client'

module SlackJiraBot
  class User
    attr_accessor :jira_username, :jira_display_name, :slack_user
    def initialize(id = "", client)
      # User has entered a slack handle.
      if (id =~ /<@/) == 0
        id = id.strip.scan(/^<@(.*)>$/).to_a.flatten[0]
        slack_user_data = client.store.users.detect { |user| user[0] == id}
      else
        # If an actual name has been supplied, try to look that up from the slack client store.
        real_name = id
        real_name_slackers = client.store.users.find_all { |user| user[1].real_name != nil }
        slack_user_data = real_name_slackers.detect { |user| user[1].real_name.include? real_name }
        # If looking up the full name doesn't work, try looking up the slack handle.
        if slack_user_data == nil
          name = real_name.split
          if name.length > 1
            # Only use the first initial of the first name
            name[0] = name[0][0]
          end
          slack_handle = name.join.downcase
          slack_user_data = client.store.users.detect { |user| user[1].name.include? slack_handle }
        end
      end
      if slack_user_data == nil
      	@jira_username = nil
      	@jira_diaplay_name = nil
      	@slack_user = nil
      else
        @slack_user = slack_user_data[1]
        real_name = @slack_user.real_name.strip.scan(/^([^(]*)(\s*\(.*\)\s*)?/).to_a.flatten[0].strip
        name = real_name.split
        if (name.length > 1)
          # Only use the first initial of the first name
          name[0] = name[0][0]
        end
        # First try guessing at the Jira username.
        @jira_username = name.join.downcase
        jira_client = JiraClient.new
        begin
          jira_user = jira_client.User.find(@jira_username)
          @jira_display_name = jira_user.attrs['displayName']
        rescue
          # If the guess was incorrect, try using a Jira search and use the first result
          # you get.
          @jira_username = ''
          @jira_display_name = ''
          url = jira_client.options[:rest_base_path] + "/user/search?username=" + URI.encode(id.strip)
          begin
            response = jira_client.get(url)
            json = JSON.parse(response.body)
            if json.length > 0
              @jira_username = json[0]['name']
              @jira_display_name = json[0]['displayName']
            end
          rescue
            puts ">>> Couldn't connect to Jira user search."
          end
        end  
      end
    end
  end
end
