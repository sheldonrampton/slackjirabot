require 'jira-ruby'

module SlackJiraBot
  class JiraClient < JIRA::Client
    def initialize
      options = {
        :username     => ENV['JIRA_USERNAME'],
        :password     => ENV['JIRA_PASSWORD'],
        :site         => ENV['JIRA_SITE'],
        :context_path => '',
        :auth_type    => :basic
      }
      super(options)
    end
  end
end
